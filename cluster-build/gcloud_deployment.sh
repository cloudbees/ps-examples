#!/usr/bin/env bash

gcloud container clusters create add-teams-test --machine-type=custom-8-53248 --enable-autoscaling --max-nodes '333' --min-nodes '10' --labels=owner=corbolj --region us-east4

kubectl create -f ssd-storage.yaml

kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass ssd -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml

kubectl create namespace cje
kubectl label namespace cje name=cje
kubectl config set-context $(kubectl config current-context) --namespace=cje

sleep 120

CLOUDBEES_CORE_IP=$(kubectl -n ingress-nginx get service ingress-nginx -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
DOMAIN_NAME="jenkins.$CLOUDBEES_CORE_IP.xip.io"

sed -e s,\${DOMAIN_NAME},$DOMAIN_NAME,g < templates/cloudbees-core.tpl > cloudbees-core.yml

kubectl apply -f cloudbees-core.yml
kubectl rollout status sts cjoc
sleep 90
kubectl exec cjoc-0 -- cat /var/jenkins_home/secrets/initialAdminPassword
echo "http://$DOMAIN_NAME/cjoc/login?from=%2Fcjoc%2F"
kubectl apply -f cjoc-external-masters.yml
kubectl apply -f networking/nginx-config-map.yaml
kubectl scale deployment.v1.apps/nginx-ingress-controller --replicas=10 -n ingress-nginx
