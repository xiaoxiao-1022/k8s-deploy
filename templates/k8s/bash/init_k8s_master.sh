#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Check if secrets.sh exists and source it
if [ ! -f "${SCRIPTPATH}/secrets.sh" ]; then
    echo "Error: secrets.sh not found"
    echo "Please provision the deployment secrets e.g. sysadmin password et al. For details please refer to documentation"
    exit 1
fi
source "${SCRIPTPATH}/secrets.sh"

# Validate password complexity
validate_password() {
    local pass=$1
    local name=$2
    if [[ ${#pass} -lt 8 ]] || \
       ! [[ $pass =~ [0-9] ]] || \
       ! [[ $pass =~ [a-z] ]] || \
       ! [[ $pass =~ [A-Z] ]] || \
       ! [[ $pass =~ ['!@%$&^#*~(){}'] ]]; then
        echo "Error: $name must be at least 8 characters and contain at least 1 number, 1 lowercase letter, 1 uppercase letter, and 1 special character (!@%$&^#*~(){})"
        exit 1
    fi
}

# Validate required passwords
validate_password "$PG_PASSWORD" "Database password"
validate_password "$SYSADMIN_PASSWORD" "Sysadmin password"

# Initialize k8s master
addr=$1
single=$2
echo "API server advertise address is $addr"

sudo kubeadm reset -f
sudo kubeadm init --image-repository $K8S_IMAGES_REPOSITORY \
    --kubernetes-version=v1.23.0 \
    --service-cidr=$K8S_SERVICE_CIDR \
    --pod-network-cidr=$K8S_POD_NETWORK_CIDR \
    --apiserver-advertise-address=$addr

mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create namespace controller
kubectl create namespace database

# Create Kubernetes secrets
kubectl create secret generic db-credentials \
    --from-literal=password="$PG_PASSWORD" \
    --namespace database

kubectl create secret generic sysadmin-credentials \
    --from-literal=password="$SYSADMIN_PASSWORD" \
    --namespace controller

# Create optional secrets if configured
if [ -n "$GOOGLE_LOGIN_CLIENT_SECRET" ]; then
    kubectl create secret generic google-signin-client-secret \
        --from-literal=client-secret="$GOOGLE_LOGIN_CLIENT_SECRET" \
        --namespace controller
fi

if [ -n "$APPLE_LOGIN_AUTH_KEY_P8_FILE" ] && [ -f "$APPLE_LOGIN_AUTH_KEY_P8_FILE" ]; then
    kubectl create secret generic apple-signin-key \
        --from-file=key.p8="$APPLE_LOGIN_AUTH_KEY_P8_FILE" \
        --namespace controller
fi

if [ -n "$SEND_EMAIL_SERVICE_ACCOUNT_FILE" ] && [ -f "$SEND_EMAIL_SERVICE_ACCOUNT_FILE" ]; then
    kubectl create secret generic send-email-credentials \
        --from-file=service-account.json="$SEND_EMAIL_SERVICE_ACCOUNT_FILE" \
        --namespace controller
fi

# Only install Cilium in multi-node mode
if [[ "$single" != "true" ]]; then
    ./install_cilium.sh
fi