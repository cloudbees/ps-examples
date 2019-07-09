#!/usr/bin/env bash

source ./set-env.sh

NAME=$CLUSTER_NAME && REGION=us-east1 && MACHINE_TYPE=n1-standard-2

MIN_NODES=1 && MAX_NODES=3

gcloud container clusters create $NAME --region $REGION \
    --machine-type $MACHINE_TYPE --enable-autoscaling \
    --num-nodes 1 --max-nodes $MAX_NODES --min-nodes $MIN_NODES

kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)


kubectl create namespace cje
