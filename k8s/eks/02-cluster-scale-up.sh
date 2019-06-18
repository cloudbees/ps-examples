#! /bin/bash


source ./set-env.sh
NODEGROUP=$(ksctl get nodegroup --cluster=$CLUSTER_NAME -o json | jq ".[] | .Name")
eksctl scale nodegroup --cluster=$CLUSTER_NAME --nodes=3 $NODEGROUP -r $AWS_DEFAULT_REGION

kubectl get nodes




