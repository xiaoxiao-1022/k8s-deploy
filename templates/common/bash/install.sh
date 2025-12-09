#!/bin/bash

function install_k8s
{
    kubeadm version >& /dev/null
    if [[ $? != 0 ]]; then
        bash install_k8s.sh
    fi
}

function install_docker
{
    echo check docker installation...
    sudo docker version >& /dev/null
    if [[ $? != 0 ]]; then
        echo docker version error. need to install docker...
        sudo apt install -y docker.io
        sudo usermod -aG docker $USER
    fi
    if [[ ! -d "/etc/docker" ]];then
        sudo mkdir /etc/docker
    fi
    sudo chmod 0777 /etc/docker
    grep exec-opts /etc/docker/daemon.json >& /dev/null
    if [[ $? != 0 ]]; then
        if [[ -f "/etc/docker/daemon.json" && $(cat /etc/docker/daemon.json | wc -l) > 0 ]];then
            echo "config docker daemon file"
            sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
            sudo jq '."exec-opts"=["native.cgroupdriver=systemd"]' /etc/docker/daemon.json.bak > /etc/docker/daemon.json
        else
            echo "add cgroupdriver to /etc/docker/daemon.json"
            sudo echo '{}' | jq '."exec-opts"=["native.cgroupdriver=systemd"]' > /etc/docker/daemon.json
        fi
    fi
    echo restarting docker daemon
    sudo systemctl restart docker
}

function install_jq
{
    jq --version >& /dev/null
    if [[ $? != 0 ]]; then
        sudo apt install -y jq
    fi
}
function close_swap
{
    sudo swapoff -a
    grep swap /etc/fstab >& /dev/null
    if [[ $? == 0 ]]; then
        sudo sed -i "s/^\([^#]*swap.*\)$/#\1/g" /etc/fstab
    fi
}

install_k8s
install_jq
install_docker
close_swap
