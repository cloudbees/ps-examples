#!/usr/bin/env bash

source ./set-env.sh
gcloud beta container clusters get-credentials $CLUSTER_NAME --region us-east1 --project $PROJECT_ID