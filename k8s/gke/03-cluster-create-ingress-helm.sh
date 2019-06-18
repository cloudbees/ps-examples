#!/usr/bin/env bash

source ./set-env.sh
#enable rbac
kubectl create -f ../yaml/cluster-roles.yaml
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
#Create CJE namespace
kubectl create  -f ../yaml/cje-namespace.yaml
kubectl create namespace ingress-nginx
kubectl get namespaces

#patch ingress see https://support.cloudbees.com/hc/en-us/articles/360020511351-Helm-install-of-stable-nginx-ingress-fails-to-deploy-the-Ingress-Controller
kubectl apply -f ../yaml/patch-nginx-ingress-clusterrole.yaml
kubectl patch deployment nginx-ingress-controller -p '{"spec":{"template":{"spec":{"containers":[{"args":["/nginx-ingress-controller","--configmap=$(POD_NAMESPACE)/nginx-configuration","--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services","--udp-services-configmap=$(POD_NAMESPACE)/udp-services","--publish-service=$(POD_NAMESPACE)/ingress-nginx","--annotations-prefix=nginx.ingress.kubernetes.io","--watch-namespace=cje"],"name":"nginx-ingress-controller"}]}}}}' -n ingress-nginx
#end patch


kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

helm init --service-account tiller


helm install --namespace ingress-nginx --name nginx-ingress stable/nginx-ingress \
             --set controller.service.externalTrafficPolicy=Local \
             --set controller.scope.enabled=true \
             --set rbac.create=true \
             --set controller.scope.namespace=$NAMESPACE


kubectl get services -n ingress-nginx
#export LB_IP=$(kubectl -n ingress-nginx \
#    get svc -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")

echo $LB_IP # It might take a while until LB is created. Repeat the `export` command if the output is empty.
