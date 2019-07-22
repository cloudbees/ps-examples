#!/usr/bin/env bash

source ./set-env.sh
#enable rbac
kubectl create -f ../yaml/cluster-roles.yaml
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl create namespace ingress-nginx
kubectl get namespaces


#patch ingress see https://support.cloudbees.com/hc/en-us/articles/360020511351-Helm-install-of-stable-nginx-ingress-fails-to-deploy-the-Ingress-Controller
kubectl apply -f ../yaml/patch-nginx-ingress-clusterrole.yaml



helm init --service-account tiller


helm install --namespace ingress-nginx --name nginx-ingress stable/nginx-ingress \
             --set controller.service.externalTrafficPolicy=Local \
             --set controller.scope.enabled=true \
             --set rbac.create=true \
             --set controller.scope.namespace=$NAMESPACE


kubectl get services -n ingress-nginx

kubectl patch deployment nginx-ingress-controller -p '{"spec":{"template":{"spec":{"containers":[{"args":["/nginx-ingress-controller","--configmap=$(POD_NAMESPACE)/nginx-configuration","--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services","--udp-services-configmap=$(POD_NAMESPACE)/udp-services","--publish-service=$(POD_NAMESPACE)/ingress-nginx","--annotations-prefix=nginx.ingress.kubernetes.io","--watch-namespace=cloudbees-core"],"name":"nginx-ingress-controller"}]}}}}' -n ingress-nginx
äkubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'


