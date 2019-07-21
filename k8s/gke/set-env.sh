#!/usr/bin/env bash
set +

export KUBE_CONFIG=~/.kube/config
export SECRET_NAME=letsenrypt-secret
#export CERT_DIR=/Users/andreascaternberg/projects/caternberg.eu/
export CERT_DIR=$(pwd)/cert
export PROJECT_ID=ps-dev-201405
#see https://cloud.google.com/apis/design/resource_names
export PROJECT_RESOURCE=//cloudresourcemanager.googleapis.com/projects/$PROJECT_ID
export GOOGLE_CREDENTIALS="google-credentials.json"
export NAMESPACE=cloudbees-core
export APP=cloudbees-core
export DOMAIN="cb-core.caternberg.eu"

if [ -f $(pwd)/"$GOOGLE_CREDENTIALS" ]
then
    export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/$GOOGLE_CREDENTIALS
else
    gcloud auth login --quiet
fi

export ACCOUNT=$(gcloud config get-value account)
export CLUSTER_NAME=ps-dev-${ACCOUNT%@*}
export SA="$ACCOUNT.iam.gserviceaccount.com"

#set defaults
gcloud config set project $PROJECT_ID
gcloud config set compute/zone us-east1
gcloud config set compute/region us-east1
gcloud components update

#ccreate credentials
gcloud iam service-accounts keys create $GOOGLE_CREDENTIALS  --iam-account=$SA

echo "CLUSTER_NAME: $CLUSTER_NAME"
echo "PROJECT_ID: $PROJECT_ID"
echo "SERVICE_ACCOUNT (SA): $SA"


exportDOMAIN_NAME ()
{
        echo "called $0 $@"
        while [ ! -n "$DOMAIN_NAME" ]
        do
            echo "DOMAIN_NAME is null, retry in 15 sec...."
            sleep 15
            export DOMAIN_NAME=$(kubectl -n ingress-nginx  get svc -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
        done
        echo "export DOMAIN_NAME=$DOMAIN_NAME"
        return 0

}
exportXIPIO ()
{
        echo "called $0 $@"
        exportDOMAIN_NAME
       # export XIPIO="cje.$DOMAIN_NAME.xip.io"
        export XIPIO="caternberg.eu"
        echo "export XIPIO=$XIPIO"
        return 0

}
