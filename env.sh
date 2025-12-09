#!/bin/sh

# Entries without a default value is to be set in your .env.local file
# in the format of VARIABLE_NAME=value, one variable per line.
# e.g. TRAEFIK_ADMIN_EMAIL=cert-admin@example.com

# Deployment name means the branding of the deployment, e.g. cylonix.
export DEPLOYMENT=${DEPLOYMENT:-cylonix}

# PG_DB_NAME is the name of the PostgreSQL database used by Cylonix manager.
export PG_DB_NAME=${PG_DB_NAME:-cylonix_manager}

# Settings for vagrant deployment for local testing.
# NODE_BOX is the Vagrant box used for the k8s nodes if to deploy locally
# for testing.
# ROOT_DOMAIN is the root domain used for the deployment.
# CONTROLLER is the name of the controller service.
export NODE_BOX=${NODE_BOX:-cylonix/ubuntu-22.04-full-10191337}
export ROOT_DOMAIN=${ROOT_DOMAIN:-cylonix.io}
export CONTROLLER=${CONTROLLER:-manager}

# Database services.
export ETCD_SERVICE_NAME=etcd-service
export DATABASE_NAMESPACE=database
export REDIS_SERVICE_NAME=redis-service
export POSTGRES_SERVICE_NAME=postgres-service
export PROMETHEUS_SERVICE_NAME=prometheus-service
export IPDRAWER_SERVICE_NAME=ipdrawer-service
export INFLUXDB_SERVICE_NAME=influxdb-service
export SUPERVISOR_SERVICE_NAME=supervisor-service

export IPDRAWER_PORT=25577

export DATABASE_VOLUME_PATH=${DATABASE_VOLUME_PATH:-/var/lib/cylonix/db/volume}
export DATABASE_CONFIG_PATH=${DATABASE_CONFIG_PATH:-/var/lib/cylonix/db/config}

# Manager service.
export MANAGER_DAEMON_CONFIG_PATH=${MANAGER_DAEMON_CONFIG_PATH:-/var/lib/cylonix}
export MANAGER_UI_CONFIG_PATH=${MANAGER_UI_CONFIG_PATH:-/var/lib/cylonix}

# Traefik service.
export TRAEFIK_CONFIG_PATH=${TRAEFIK_CONFIG_PATH:-/var/lib/cylonix}
export TRAEFIK_ADMIN_EMAIL=${TRAEFIK_ADMIN_EMAIL}

# Kubernetes settings.
export K8S_ADD_APT_REPO_SCRIPT=${K8S_ADD_APT_REPO_SCRIPT:-add_k8s_apt.sh}
export K8S_IMAGES_REPOSITORY=${K8S_IMAGES_REPOSITORY:-registry.k8s.io}
export K8S_SERVICE_CIDR=${K8S_SERVICE_CIDR:-172.25.0.0/16}
export K8S_POD_NETWORK_CIDR=${K8S_POD_NETWORK_CIDR:-10.82.0.0/16}

# Sysadmin user settings.
export CYLONIX_ADMIN_EMAIL=${CYLONIX_ADMIN_EMAIL}
export CYLONIX_ADMIN_FIRST_NAME=${CYLONIX_ADMIN_FIRST_NAME:-Sys}
export CYLONIX_ADMIN_LAST_NAME=${CYLONIX_ADMIN_LAST_NAME:-Admin}

# Send email settings.
# Default to be using Google GMAIL API.
export SEND_EMAIL_PROVIDER=${SEND_EMAIL_PROVIDER:-google}
export SEND_EMAIL_FROM_ADDRESS=${SEND_EMAIL_FROM_ADDRESS:-contact@$cylonix.io}
export SEND_EMAIL_LOCAL_NAME=${SEND_EMAIL_LOCAL_NAME:-Cylonix}
export SEND_EMAIL_SERVICE_ACCOUNT_FILE=${SEND_EMAIL_SERVICE_ACCOUNT_FILE:-/etc/secrets/google/service-account.json}

# Headscale settings.
export HEADSCALE_BASE_DOMAIN=${HEADSCALE_BASE_DOMAIN:-local.cylonix.io}
