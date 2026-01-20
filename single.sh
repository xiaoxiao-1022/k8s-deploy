#! /bin/bash

# To be bundled and used in single node deployment.
cd common/bash
bash install.sh
cd ../..

cd database/bash
bash deploy.sh
cd ../..

cd k8s/bash
# 自动获取主机的主 IP 地址
HOST_IP=$(hostname -I | awk '{print $1}')
bash start.sh -s -r -a $HOST_IP
cd ../..

echo "Single node deployment completed. You can now access the Cylonix controller."