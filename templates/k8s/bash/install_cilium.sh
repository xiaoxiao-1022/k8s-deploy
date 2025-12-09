#!/bin/bash

function install_helm
{
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
}
function initArch() {
  ARCH=$(uname -m)
  case $ARCH in
    armv5*) ARCH="armv5";;
    armv6*) ARCH="armv6";;
    armv7*) ARCH="arm";;
    aarch64) ARCH="arm64";;
    x86) ARCH="386";;
    x86_64) ARCH="amd64";;
    i686) ARCH="386";;
    i386) ARCH="386";;
  esac
}

function initOS() {
  OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')
  case "$OS" in
    mingw*|cygwin*) OS='windows';;
  esac
}

function install_cilium_cli
{
    CILIUM_CLI_VERSION="v0.15.0"
    CILIUM_TAR_FILE="cilium-${OS}-${ARCH}.tar.gz"
    curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-${OS}-${ARCH}.tar.gz
    sudo tar -C /usr/local/bin -xzvf cilium-${OS}-${ARCH}.tar.gz
}
initArch
initOS
helm version >& /dev/null
if [[ $? != 0 ]]; then
    install_helm
    if [[ $? != 0 ]]; then
        echo "failed to install helm cmd $?"
        exit 1 
    fi
fi

cilium version >& /dev/null
if [[ $? != 0 ]]; then
    install_cilium_cli
    if [[ $? != 0 ]]; then
        echo "failed to install cilium cli $?"
        exit 1 
    fi
fi

cilium install $@ --version 1.15.4 \
    --set image.useDigest=false \
    --set image.repository=cylonix/cilium \
    --set operator.image.useDigest=false \
    --set ipv4NativeRoutingCIDR=172.28.0.0/16 \
    --set ipam.operator.clusterPoolIPv4PodCIDRList=172.28.0.0/16 \
    --set ipam.operator.clusterPoolIPv4MaskSize=24 \
    --set routingMode=native \
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,port-distribution,http}" \
    --set bpf.masquerade=true \
    --set kubeProxyReplacement="true"