#!/usr/bin/env bash

source ./set-env.sh

echo "#######list-grantable-roles#######"
gcloud iam list-grantable-roles $PROJECT_RESOURCE --format json
echo "#######service-accounts keyss#######"
gcloud iam service-accounts keys list  --iam-account $SA --format json