#!/usr/bin/env bash

source ./set-env.sh
gcloud beta container clusters get-credentials $CLUSTER_NAME
#gcloud beta container clusters get-credentials ps-dev-acaternberg --region us-east1 --project ps-dev-201405