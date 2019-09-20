#!/usr/bin/env bash

source ./set-env.sh


kubectl delete \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.23.0/deploy/mandatory.yaml
kubectl delete \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.23.0/deploy/provider/cloud-generic.yaml


kubectl delete \
    -f https://raw.githubusercontent.com/vfarcic/k8s-specs/master/helm/tiller-rbac.yml

