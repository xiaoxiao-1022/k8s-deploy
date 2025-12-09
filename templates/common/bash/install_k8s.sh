#!/bin/sh -eux

set -e

sudo apt-get update
sudo apt-get install -y gnupg apt-transport-https software-properties-common curl

sudo mkdir -p -m 755 /etc/apt/keyrings
sh ./${K8S_ADD_APT_REPO_SCRIPT}

sudo apt update
sudo apt-cache madison kubectl
sudo apt-get install -y kubelet=1.23.5-00 kubeadm=1.23.5-00 kubectl=1.23.5-00
sudo apt-mark hold kubelet kubeadm kubectl
