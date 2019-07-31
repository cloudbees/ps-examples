#!/usr/bin/env bash


kubectl patch statefullset  cjoc  -p '{"spec":{"template":{"spec":{"containers":[{"args":["/nginx-ingress-controller","--configmap=$(POD_NAMESPACE)/nginx-configuration","--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services","--udp-services-configmap=$(POD_NAMESPACE)/udp-services","--publish-service=$(POD_NAMESPACE)/ingress-nginx","--annotations-prefix=nginx.ingress.kubernetes.io","--watch-namespace=cloudbees-core"],"name":"nginx-ingress-controller"}]}}}}' -n ingress-nginx
#end patch
