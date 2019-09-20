#! /bin/bash


source ./cje-delete.sh

LB_NAME=$(aws elb describe-load-balancers | jq -r \
    ".LoadBalancerDescriptions[0] \
    | select(.SourceSecurityGroup.GroupName \
    | contains (\"k8s-elb\")).LoadBalancerName")

#aws elb delete-load-balancer \
#    --load-balancer-name $LB_NAME

eksctl delete cluster -n $CLUSTER_NAME
#aws cloudformation delete-stack --stack-name   eksctl-$CLUSTER_NAME-cluster
aws cloudformation list-stacks | jq '.StackSummaries[]  | select(.StackName == "$CLUSTER_NAME") | .StackStatus'
#aws cloudformation list-stacks



#TODO:  In case of error similar to: "Not able to delete stack because VPC is mapped"
#try to delete assigned Elastic IPS as described: https://stackoverflow.com/questions/45027830/cant-delete-aws-internet-gateway
# Then in AWS , delete in that order:  the related Network interface,the Loadbalancer  and the VPC
# run  aws cloudformation   delete-stack --stack-name eksctl-devops24-cluster   again
#aws ec2 delete-network-interface  --network-interface-id <value>
#aws ec2   delete-load-balancer  --load-balancer-name <value>
#TODO get VPC id  with jq
#aws ec2    describe-vpcs  | jq '.VPCs[]  | select(.Tags.Value == "eksctl-devops24-cluster/VPC") | .VPCid'
#aws ec2  delete-vpc  --vpc-id <value>

aws ec2    describe-vpcs   --filters "Name=Tag:key,Values=eksctl-devops24-cluster/VPC"










