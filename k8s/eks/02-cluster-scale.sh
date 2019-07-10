#! /bin/bash


source ./set-env.sh
echo -n "Enter new node size and press [ENTER]: "
read SIZE
echo "Scaling cluster $CLUSTER_NAME to size $SIZE"
NODEGROUP=$(ksctl get nodegroup --cluster=$CLUSTER_NAME -o json | jq ".[] | .Name")
eksctl scale nodegroup --cluster=$CLUSTER_NAME --nodes=$SIZE $NODEGROUP -r $AWS_DEFAULT_REGION

kubectl get nodes




