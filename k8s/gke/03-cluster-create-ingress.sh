#!/usr/bin/env bash

source ./set-env.sh



#patch ingress see https://support.cloudbees.com/hc/en-us/articles/360020511351-Helm-install-of-stable-nginx-ingress-fails-to-deploy-the-Ingress-Controller
kubectl apply -f yaml/patch-nginx-ingress-clusterrole.yaml

#Deploy NGINX Ingress Controller

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.23.0/deploy/mandatory.yaml
#Deploy the service creating the Load Balancer

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.23.0/deploy/provider/cloud-generic.yaml


kubectl get services -n ingress-nginx
