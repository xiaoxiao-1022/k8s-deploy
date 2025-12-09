#!/bin/bash

single=false
reset=false
function usage
{
    echo $0 -r -s -a \<ADDRESS\>
    echo -r kubeadmin reset
    echo -s use single node
}
while getopts ":hrsa:" o; do
  case "${o}" in
    h)
      usage
      ;;
    r)
      reset=true
      ;;
    s)
      single=true
      ;;
    a)
      addr=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

echo Script path $SCRIPTPATH
if [[ "$reset" == "true" ]];then
    echo Reset k8s...
    ${SCRIPTPATH}/init_k8s_master.sh $addr $single
fi

# Don't expect failures starting from here.
set -e

if [[ "$single" == "true" ]];then
    kubectl label node $HOSTNAME database=
    kubectl label node $HOSTNAME manage-daemon=
    kubectl taint nodes $HOSTNAME node-role.kubernetes.io/master-
    #kubectl taint nodes $HOSTNAME node-role.kubernetes.io/control-plane:NoSchedule-
fi
echo waiting....
sleep 15s

# Change dns config to work around the following issue:
# https://github.com/kubernetes/kubernetes/issues/118461#issuecomment-1974924360
sudo bash -c 'cat << EOF > /etc/resolve_kubelet.conf
nameserver 4.2.2.1
nameserver 192.168.121.1
EOF'
sudo sed -i "s/^.*resolvConf:.*$/resolvConf: \/etc\/resolve_kubelet.conf/g" /var/lib/kubelet/config.yaml
sudo systemctl restart kubelet.service
kubectl rollout restart -n kube-system deployment/coredns
echo waiting kubelet and coredns to restart....
sleep 15s

dash="================="
echo $dash init database pods $dash
kubectl apply -f ${SCRIPTPATH}/../database
echo $dash init manage daemon pods $dash
kubectl apply -f ${SCRIPTPATH}/../manager
for namespace in $MANAGE_NAMESPACES; do
    echo $dash init manage daemon pods for $namespace $dash
    kubectl apply -f ${SCRIPTPATH}/../manager/$namespace
done
echo $dash init traefic $dash
kubectl apply -f ${SCRIPTPATH}/../traefik/static/crd-rbac.yml -f ${SCRIPTPATH}/../traefik/static/define-v1.yml
sleep 2s
echo $dash set traefic routes $dash
kubectl apply -f ${SCRIPTPATH}/../traefik/app/app.yml  -f ${SCRIPTPATH}/../traefik/app/ingress_route.yml 
