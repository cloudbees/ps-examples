#! /bin/bash


source ./set-env.sh

eksctl create cluster -n $CLUSTER_NAME --kubeconfig cluster/kubecfg-eks \
    --node-type t3.2xlarge --nodes 3 -r $AWS_DEFAULT_REGION

kubectl get nodes




