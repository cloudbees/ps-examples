#!/usr/bin/env bash



source ./set-env.sh

#enable rbac
kubectl create -f yaml/cluster-roles.yaml
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl create namespace $NAMESPACE
kubectl get namespaces

#patch ingress see https://support.cloudbees.com/hc/en-us/articles/360020511351-Helm-install-of-stable-nginx-ingress-fails-to-deploy-the-Ingress-Controller
#kubectl apply -f yaml/patch-nginx-ingress-clusterrole.yaml

kubectl describe sa tiller --namespace kube-system
kubectl describe clusterrolebinding tiller

helm init --upgrade --service-account tiller

#see https://github.com/cccaternberg/ps-core-helm-example


#see https://go.cloudbees.com/docs/cloudbees-core/cloud-install-guide/kubernetes-helm-install/#install-core-helm
helm repo add cloudbees https://charts.cloudbees.com/public/cloudbees
helm repo update
export SECRET_NAME=letsencrypt-secret
#helm delete $APP
kubectl config set-context $(kubectl config current-context) --namespace=$NAMESPACE
#helm install --name $APP --set OperationsCenter.HostName="$XIPIO" --namespace $NAMESPACE cloudbees/$APP
echo "helm install  --name $APP \
    --set OperationsCenter.HostName="$DOMAIN" \
    --set OperationsCenter.Ingress.tls.Enable=true \
    --set OperationsCenter.ServiceType='ClusterIP' \
    --set nginx-ingress.Enabled=true \
    --namespace="$NAMESPACE" \
    cloudbees/$APP"



helm  upgrade --debug --install     $APP \
    --set OperationsCenter.HostName="$DOMAIN" \
    --set OperationsCenter.Ingress.tls.Enable=true \
    --set nginx-ingress.Enabled=true \
    --set OperationsCenter.ServiceType='ClusterIP' \
    --set OperationsCenter.Ingress.tls.SecretName=$SECRET_NAME \
    --namespace="$NAMESPACE" \
    cloudbees/$APP


helm ls --all $APP

#Wait until CJOC is rolled out
#kubectl rollout status sts cjoc

echo "let*s wait 60  sec for the container......"
sleep 60
#Read the admin password
kubectl exec cjoc-0 -- cat /var/jenkins_home/secrets/initialAdminPassword

#kubectl exec cjoc-0 cat /var/jenkins_home/secrets/initialAdminPassword
#Login with the password from step above  and the username: admin
open     https://$DOMAIN/cjoc/

#cd ../../../ps-core-helm-example/./cje-install-gke.sh   $XIPIO  $SECRET_NAME $CLUSTER_NAME

