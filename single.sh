#! /bin/bash

# To be bundled and used in single node deployment.
cd common/bash
bash install.sh
cd ../..

cd database/bash
bash deploy.sh
cd ../..

cd k8s/bash
# 获取主机的实际 IP 地址（避免使用 Docker 桥接 IP）
HOST_IP=$(ip route get 1 2>/dev/null | awk '{print $7;exit}')
# 如果上述方法失败，回退到 hostname -I
if [ -z "$HOST_IP" ]; then
    HOST_IP=$(hostname -I | awk '{print $1}')
fi
if [ -z "$HOST_IP" ]; then
    echo "Error: Could not detect host IP address" >&2
    exit 1
fi

# 修复主机名解析问题
echo "$(hostname -I | awk '{print $1}') $(hostname)" | sudo tee -a /etc/hosts 2>/dev/null || true

bash start.sh -s -r -a "$HOST_IP"
cd ../..

echo "Single node deployment completed. You can now access the Cylonix controller."