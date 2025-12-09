# Cylonix Deployment with k8s

This repository contains the code to deploy Cylonix controller and the services
in a k8s environment. The minimal deployment is one node i.e. without data plane
worker nodes for WireGuard gateway, Firewall and VPP routing.

## 1. Configure Environment Variables

Edit .env file to set the required environment variables. Please refer to
the documentation on each of the setting means.

## 2. Generate Configuration Files

Run `make generate` to create `gen/bundle.tar`

## 3. Deploy Configuration Files

### 3.1 For New K8s Environment Setup

Upload gen/bundle.tar to your VM that will be the k8s nodes. Then execute the
following command:

```bash
tar -xvf bundle.tar
```

#### Single Node Deployment

```bash
cd gen
bash single.sh
```

#### Multi-node Deployment

1. On Master Node:

    ```bash
    cd gen
    bash master.sh
    ```

2. On Worker Nodes:

    ```bash
    cd gen/common/bash
    bash install.sh
    cd
    ```

    ```bash
    sudo kubeadm join <master k8s ip>:<master k8s port> --token <token> \
        --discovery-token-ca-cert-hash sha256:<sha256 hash>
    ```

    The above command will be printed on the master node console when running install.sh

3. On Master Node:

    - Check nodes status with:

    ```bash
    kubectl get node -A

    NAME            STATUS   ROLES                  AGE     VERSION
    k8s-master      Ready    control-plane,master   107m    v1.23.5
    k8s-worker-01   Ready    <none>                 8m18s   v1.23.5
    k8s-worker-02   Ready    <none>                 2m6s    v1.23.5
    ```

    - Deploy database on k8s-worker-01:

        ```bash
        kubectl label node k8s-worker-01 database=
        ```

    - Deploy manage and UI on k8s-worker-02:

        ```bash
        kubectl label node k8s-worker-02 manage-daemon=
        ```

    - Then run:

        ```bash
        cd gen/k8s/bash
        bash start.sh
        ```

## 4. Clean Configuration Files

make clean
