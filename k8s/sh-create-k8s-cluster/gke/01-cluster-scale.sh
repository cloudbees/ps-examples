#!/usr/bin/env bash

source ./set-env.sh

#NAME=$CLUSTER_NAME && REGION=us-east1 && MACHINE_TYPE=n1-standard-2

echo -n "Enter new node size and press [ENTER]: "
read SIZE
echo "Scaling cluster $CLUSTER_NAME to size $SIZE"
NODE_POOL=$(gcloud container node-pools list --cluster  $CLUSTER_NAME --format json |  jq -r  '.[].name')
echo "POOL: $NODE_POOL"
gcloud container clusters resize $CLUSTER_NAME --node-pool $NODE_POOL     --size $SIZE
