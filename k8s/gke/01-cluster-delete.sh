#!/usr/bin/env bash

source ./set-env.sh

NAME=$CLUSTER_NAME && REGION=us-east1 && MACHINE_TYPE=n1-standard-2
gcloud container clusters delete $NAME