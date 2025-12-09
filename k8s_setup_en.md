# How to set up the deployment environment for k8s

## 1. Installation Environment (Minimum 1 node required - 1 master, 2 optional worker nodes)

Steps 1.1 - 1.3 must be performed on each node:

### 1.1 Install Tools

```bash
# Update apt repository
sudo apt-get update
# Install SSL support for apt
sudo apt-get install -y apt-transport-https
# Download GPG key
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
# Add apt repository
sudo apt-add-repository "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main"
# Check available versions
sudo apt-cache madison kubectl
# Install specific version
sudo apt-get install -y kubelet=1.23.5-00 kubeadm=1.23.5-00 kubectl=1.23.5-00
# Prevent automatic updates
sudo apt-mark hold kubelet kubeadm kubectl
```

### 1.2 Disable Swap

```bash
sudo swapoff -a
```

Comment out the swap line in /etc/fstab

### 1.3 Modify Docker Configuration

```bash
sudo vi /etc/docker/daemon.json
```

```json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "http://hub-mirror.c.163.com",
        "https://docker.mirrors.ustc.edu.cn",
        "https://dockerhub.azk8s.cn",
        "https://mirror.ccs.tencentyun.com",
        "https://registry.cn-hangzhou.aliyuncs.com",
        "https://docker.mirrors.ustc.edu.cn"
    ]
}
```

Change native.cgroupdriver to systemd in exec-opts
Restart docker

### 1.4 If kubelet has DNS issues during startup

Kubelet supports up to 3 DNS configurations. Configure through a custom resolve file.
In /var/lib/kubelet/config.yaml, set resolvConf to custom file:

```yaml
resolvConf: /etc/resolv_self.conf
```

Restart kubelet: `sudo systemctl restart kubelet.service`

Content of /etc/resolv_self.conf:

```bash
nameserver 223.5.5.5
nameserver 192.168.121.1
```

## 2. Master Node Setup

```bash
sudo kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers
sudo kubeadm init --image-repository registry.aliyuncs.com/google_containers --kubernetes-version=v1.23.5 --service-cidr=172.25.0.0/16 --pod-network-cidr=10.82.0.0/16 --apiserver-advertise-address=192.168.121.101 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Note: apiserver-advertise-address should be the master node's external IP

After running kubeadm init on master node, you'll see a command similar to:

```bash
kubeadm join 192.168.121.101:6443 --token w83goi.bo2yjq45xngs0t3u --discovery-token-ca-cert-hash sha256:5a1b52d73eec7ef94162977577940d594220095609ee57d26c31c52d0001c9e2
```

To modify nodePort range: `sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml`
Add `--service-node-port-range=1-32767`, then restart kubelet: `sudo systemctl restart kubelet.service`

## 3. Worker Node Setup (optional)

Run the kubeadm join command from step 2

## 4. Back to Master Node

### 4.1 Add Labels and Namespaces

Add labels:

```bash
kubectl label node db-worker-01 role=database
kubectl label node manage-worker-01 role=manage-daemon
```

Create namespaces:

```bash
kubectl create namespace sase
kubectl create namespace database
```

### 4.2 Install Cilium (optional)

4.2.1. Download and install Cilium CLI

```bash
# Download from https://github.com/cilium/cilium-cli/releases/tag/v0.15.0
tar -xvf cilium-linux-amd64.tar.gz
sudo mv cilium/cilium /usr/bin
```

4.2.2. Deploy Cilium

```bash

cilium install -f cilium/values.yaml --version 1.15.4 --set ipv4NativeRoutingCIDR=172.28.0.0/16 --set ipam.operator.clusterPoolIPv4PodCIDRList=172.28.0.0/16 --set ipam.operator.clusterPoolIPv4MaskSize=24
```
