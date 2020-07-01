#!/usr/bin/env bash

source ./set-env.sh



IAM_USER=${ACCOUNT%@*}
gcloud iam service-accounts create  $IAM_USER

policybinding (){
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$IAM_USER@$PROJECT_ID.iam.gserviceaccount.com" \
    --role "$1"
}

echo $policybinding "roles/owner"
echo $policybinding "roles/iam.serviceAccountUser"





gcloud iam service-accounts keys create $GOOGLE_CREDENTIALS --iam-account "$IAM_USER@$PROJECT_ID.iam.gserviceaccount.com"

export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/$GOOGLE_CREDENTIALS