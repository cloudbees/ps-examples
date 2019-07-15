#!/usr/bin/env bash

source ./set-env.sh

helm del --purge $APP

# Teardown

##Stopping Operations Center
#kubectl scale statefulsets/cjoc --replicas=0
##Delete the services, pods, ingress
#kubectl delete -f cloudbees-core.yml
##Delete remaining pods, data
#kubectl delete pod,statefulset,pvc,ingress,service -l com.cloudbees.cje.tenant
##Delete everything else, including started masters and all data in the namespace!!!
#kubectl delete svc --all
#kubectl delete statefulset --all
#kubectl delete pod --all
#kubectl delete ingress --all
#kubectl delete pvc --all
