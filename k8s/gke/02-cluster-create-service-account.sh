#!/usr/bin/env bash

source ./set-env.sh

IAM_USER=$(gcloud config get-value account)
IAM_USER=${IAM_USER%@*}
gcloud iam service-accounts create  $IAM_USER

policybinding (){
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$IAM_USER@$PROJECT_ID.iam.gserviceaccount.com" \
    --role "$1"
}

echo $policybinding "roles/owner"
echo $policybinding "roles/iam.serviceAccountUser"





gcloud iam service-accounts keys create google-credentials.json --iam-account "$IAM_USER@$PROJECT_ID.iam.gserviceaccount.com"

export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/google-credentials.json