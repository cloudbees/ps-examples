#! /bin/bash


#kubectl apply \
#   -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

kubectl apply \
     -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/1cd17cd12c98563407ad03812aebac46ca4442f2/deploy/mandatory.yaml

#kubectl apply \
 #   -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/aws/service-l4.yaml
 kubectl apply \
    -f    https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/aws/l4/service-l4.yaml

#kubectl apply \
#    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/aws/patch-configmap-l4.yaml


sleep 10
IP=$(kubectl -n ingress-nginx get svc ingress-nginx \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")

echo $IP