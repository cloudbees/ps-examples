#!/usr/bin/env bash


source ./set-env.sh

$DOMAIN
#see https://support.cloudbees.com/hc/en-us/articles/360018094412-Deploy-Self-Signed-Certificates-in-Masters-and-Agents-Custom-Location-

#delete old secret

kubectl delete secret $SECRET_NAME --namespace=ingress-nginx
kubectl delete secret $SECRET_NAME
#create secret
kubectl create secret tls $SECRET_NAME --key $(pwd)/privkey1.pem --cert $(pwd)/fullchain1.pem --namespace=$NAMESPACE
#kubectl create secret tls $SECRET_NAME --key $(pwd)/privkey1.pem --cert $(pwd)/fullchain1.pem --namespace=ingress-nginx
kubectl describe  secret $SECRET_NAME --namespace=$NAMESPACE


