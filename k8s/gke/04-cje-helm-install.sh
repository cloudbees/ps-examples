#!/usr/bin/env bash



source ./set-env.sh



exportXIPIO
#Endpint calculating
export ENDPOINT="https://$DOMAIN_NAME"
echo "current endpoint: $ENDPOINT"


#see https://github.com/cccaternberg/ps-core-helm-example


#see https://go.cloudbees.com/docs/cloudbees-core/cloud-install-guide/kubernetes-helm-install/#install-core-helm
helm repo add cloudbees https://charts.cloudbees.com/public/cloudbees
helm repo update

kubectl create namespace $NAMESPACE
kubectl config set-context $(kubectl config current-context) --namespace=$NAMESPACE
#helm install --name $APP --set OperationsCenter.HostName="$XIPIO" --namespace $NAMESPACE cloudbees/$APP
echo "helm upgrade --install   $APP \
    --set OperationsCenter.HostName=\"https://$XIPIO\" \
    --set OperationsCenter.Ingress.tls.Enable=true \
    --set OperationsCenter.Ingress.tls.SecretName=\"$SECRET_NAME\" \
    --namespace=\"$NAMESPACE\" \
    cloudbees/cloudbees-core"

helm upgrade --install  $APP \
    --set OperationsCenter.HostName="$XIPIO" \
    --set OperationsCenter.Ingress.tls.Enable=true \
    --set OperationsCenter.ServiceType='ClusterIP' \
    --set nginx-ingress.Enabled=true \
    --set OperationsCenter.Ingress.tls.SecretName="$SECRET_NAME" \
    --namespace="$NAMESPACE" \
    cloudbees/cloudbees-core


kubectl exec cjoc-0 cat /var/jenkins_home/secrets/initialAdminPassword
#Login with the password from step above  and the username: admin
open     https://$XIPIO/cjoc/

#cd ../../../ps-core-helm-example/./cje-install-gke.sh   $XIPIO  $SECRET_NAME $CLUSTER_NAME

