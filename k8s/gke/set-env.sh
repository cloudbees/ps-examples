#!/usr/bin/env bash

if [ -f $(pwd)/google-credentials.json ]
then
    export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/google-credentials.json
else
    gcloud auth login --quiet
fi
CLUSTER_NAME=$(gcloud config get-value account)
export CLUSTER_NAME=ps-dev-${CLUSTER_NAME%@*}
export KUBE_CONFIG=~/.kube/config
export PROJECT_ID=ps-dev-201405
echo $CLUSTER_NAME
export NAMESPACE=cje


