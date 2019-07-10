#!/usr/bin/env bash

export KUBE_CONFIG=~/.kube/config
export PROJECT_ID=ps-dev-201405
#see https://cloud.google.com/apis/design/resource_names
export PROJECT_RESOURCE=//cloudresourcemanager.googleapis.com/projects/$PROJECT_ID
export GOOGLE_CREDENTIALS="google-credentials.json"
export NAMESPACE=cje
if [ -f $(pwd)/"$GOOGLE_CREDENTIALS" ]
then
    export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/$GOOGLE_CREDENTIALS
else
    gcloud auth login --quiet
fi

export ACCOUNT=$(gcloud config get-value account)
export CLUSTER_NAME=ps-dev-${ACCOUNT%@*}
export SA="$ACCOUNT.iam.gserviceaccount.com"

#set defaults
gcloud config set project $PROJECT_ID
gcloud config set compute/zone us-east1
gcloud config set compute/region us-east1
gcloud components update

#ccreate credentials
gcloud iam service-accounts keys create $GOOGLE_CREDENTIALS  --iam-account=$SA

echo "CLUSTER_NAME: $CLUSTER_NAME"
echo "PROJECT_ID: $PROJECT_ID"
echo "SERVICE_ACCOUNT (SA): $SA"



