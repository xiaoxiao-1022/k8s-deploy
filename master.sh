#! /bin/bash

# This script is used to set up the master node for a Kubernetes cluster.
cd common/bash
bash install.sh
cd ../..
cd k8s/bash
bash k8s_master_init.sh
cd ../..
echo "Master node setup completed. You can now join worker nodes to this master."
