#!/usr/bin/env bash

GOOGLE_CREDENTIALS="google-credentials.json"
if [ -f $(pwd)/"$GOOGLE_CREDENTIALS" ]
then
    export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/$GOOGLE_CREDENTIALS
else
    gcloud auth login --quiet
    SA="$(gcloud config get-value account).iam.gserviceaccount.com"
   # gcloud iam list-grantable-roles
    gcloud iam service-accounts keys list  --iam-account $SA
    gcloud iam service-accounts keys create $GOOGLE_CREDENTIALS  --iam-account=$SA

fi
export CLUSTER_NAME=$(gcloud config get-value account)
export CLUSTER_NAME=ps-dev-${CLUSTER_NAME%@*}
export KUBE_CONFIG=~/.kube/config
export PROJECT_ID=ps-dev-201405
gcloud config set project $PROJECT_ID
#gcloud config set compute/zone us-east1-b,us-east1-d,us-east1-c
gcloud config set compute/zone us-east1
gcloud config set compute/region us-east1
gcloud components update
echo "CLUSTER_NAME: $CLUSTER_NAME"
export NAMESPACE=cje


