#! /bin/bash

# To be bundled and used in single node deployment.
cd common/bash
bash install.sh
cd ../..

cd database/bash
bash deploy.sh
cd ../..

cd k8s/bash
bash start.sh -s -r
cd ../..

echo "Single node deployment completed. You can now access the Cylonix controller."