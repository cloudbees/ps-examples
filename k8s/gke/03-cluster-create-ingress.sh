#!/usr/bin/env bash

source ./set-env.sh

#kubectl apply -f     https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
kubectl apply \
  -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/1cd17cd12c98563407ad03812aebac46ca4442f2/deploy/mandatory.yaml
#kubectl apply -f     https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml
kubectl apply \
   -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/1cd17cd12c98563407ad03812aebac46ca4442f2/deploy/provider/cloud-generic.yaml

kubectl apply --record \
    -f https://raw.githubusercontent.com/vfarcic/k8s-specs/master/helm/tiller-rbac.yml

helm init --service-account tiller

kubectl -n kube-system rollout status deploy tiller-deploy

echo "wait 60 sec for DNS"
sleep 60

export LB_IP=$(kubectl -n ingress-nginx \
    get svc -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")

echo $LB_IP # It might take a while until LB is created. Repeat the `export` command if the output is empty.

echo "cje.$LB_IP.xip.io"