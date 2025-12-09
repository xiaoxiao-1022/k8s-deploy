#!/bin/bash

set -e

etcd_volume=${DATABASE_VOLUME_PATH}/etcd/data
pg_entrypoint=${DATABASE_VOLUME_PATH}/postgres/entrypoint
prometheus_config=${DATABASE_CONFIG_PATH}/prometheus
prometheus_data=${DATABASE_VOLUME_PATH}/prometheus/data

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

sudo mkdir -m 0777 -p $etcd_volume
sudo mkdir -m 0777 -p $pg_entrypoint
sudo mkdir -m 0777 -p $prometheus_config
sudo mkdir -m 0777 -p $prometheus_data

sudo cp ${SCRIPTPATH}/../postgres/entrypoint.sh ${pg_entrypoint}/.
sudo cp ${SCRIPTPATH}/../prometheus/prometheus.yml ${prometheus_config}/.
sudo cp ${SCRIPTPATH}/../prometheus/targets.json ${prometheus_config}/.

sudo chmod +x ${pg_entrypoint}/*.sh
