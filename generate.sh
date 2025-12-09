#! /bin/bash

# Overwrite env from .env.local
sed /^\s*#/d .env.local | sed /^\s*$/d | sed 's/^/export /' > /tmp/env.local
. /tmp/env.local
. ./env.sh
rm -f /tmp/env.local

function generate
{
    template_dir=templates/$1
    dist_dir=gen/$2
    if [[ "$dist_dir" == "gen/" ]]; then
        dist_dir=gen/$1
    fi
    mode=$3
    env_values=$4

    mkdir -p $dist_dir
    find "$template_dir" -follow -type f  -print | while read -r f ; do
        filename=`echo $f | awk -F '/' '{print $NF}'`
        if [[ "$mode" == "env" ]]; then
            envsubst $env_values < $f > ${dist_dir}/$filename
        elif [[ "$mode" == "cp" ]]; then
            cp $f ${dist_dir}/$filename
        fi
    done
}

HOSTINFO_ENV='$K8S_ADVERTISE_ADDRESS;$K8S_POD_NETWORK_CIDR;$K8S_SERVICE_CIDR;'
HOSTINFO_ENV+='$K8S_IMAGES_REPOSITORY;$MANAGE_NAMESPACES;$TRAEFIK_CONFIG_PATH;'
HOSTINFO_ENV+='$MANAGER_UI_CONFIG_PATH;$MANAGER_DAEMON_CONFIG_PATH'

namespace=${DEPLOYMENT}
export NAMESPACE_RAW=$namespace
export NAMESPACE_REPLACE=`echo $namespace | tr [.] -`

generate common/bash         "" env
generate database/bash       "" env '$DATABASE_VOLUME_PATH;$DATABASE_CONFIG_PATH'
generate database/postgres   "" env '$PG_DB_NAME;$PG_USERNAME'
generate database/prometheus "" cp
generate k8s/bash            "" env $HOSTINFO_ENV
generate k8s/database        "" env
generate k8s/manager         "" env
generate k8s/supervisor      "" env
generate k8s/traefik/app     "" env
generate k8s/traefik/static  "" cp
generate vagrant             "" env

# Generate traefik rules for namespace routing that maps a namespace to its own
# private service pods.
rule_file=/tmp/$RANDOM.yml
rule_template=templates/k8s/traefik/namespace_rule/ingress_rule.yml
echo generating namespace rules for [$MANAGE_NAMESPACES]
for namespace in $MANAGE_NAMESPACES; do
    export NAMESPACE_RAW=$namespace
    export NAMESPACE_REPLACE=`echo $namespace | tr [.] -`
    generate k8s/manager "k8s/manager/$namespace" env
    if [[ -f "$rule_template" ]]; then
        echo Generate $namespace rule file with $rule_template to $rule_file
        envsubst < $rule_template >> $rule_file
    fi
done
traefik_route_file=gen/k8s/traefik/app/ingress_route.yml
if [[ -f "$traefik_route_file" && -f "$rule_file" ]]; then
    cat $rule_file >> $traefik_route_file
fi

chmod +x gen/k8s/bash/*.sh gen/common/bash/*.sh gen/database/bash/*.sh

# Bundle
rm -f /tmp/bundle.tar
cp single.sh gen/single.sh
cp master.sh gen/master.sh
tar -cvf /tmp/bundle.tar gen
mv /tmp/bundle.tar gen/.

echo "Bundle created at gen/bundle.tar"