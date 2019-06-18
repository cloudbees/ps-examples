#! /bin/bash


#https://stackoverflow.com/questions/50309012/deploy-nginx-ingress-in-aks-without-rbac-issue

export CLUSTER_NAME=cje

mkdir -p cluster
export KUBECONFIG="$(pwd)/cluster/kubecfg-eks"


cat cje2-creds

export AWS_ACCESS_KEY_ID=$(cat cje2-creds |  jq -r '.AccessKey.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(cat cje2-creds | jq -r '.AccessKey.SecretAccessKey')
#export AWS_DEFAULT_REGION=us-west-2
export AWS_DEFAULT_REGION=us-east-2
export ZONES=$(aws ec2 describe-availability-zones --region $AWS_DEFAULT_REGION | jq -r '.AvailabilityZones[].ZoneName' | tr '\n' ',' | tr -d ' ')
ZONES=${ZONES%?}
echo "Zones: $ZONES"
echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo "CJE_DIR: $CJE_DIR"
echo "KUBECONFIG: $KUBECONFIG"

#FIXME:no such option: posix   (MacOS)
#( set -o posix ; set )

getXIPIO ()
{
        echo "called $0 $1"
        DOMAIN_NAME=$(kubectl -n ingress-nginx get svc ingress-nginx   -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
        export DOMAIN_NAME="cje.$(dig +short $DOMAIN_NAME | tail -n 1).xip.io"
        return 0

}









