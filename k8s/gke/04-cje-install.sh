#!/usr/bin/env bash


source ./set-env.sh

kubectl create namespace $NAMESPACE
CJE_DIR=cloudbees-core_2.176.1.4_kubernetes
cd $CJE_DIR
#bakup org files
if [ ! -f cloudbees-core.yml.def ]
then
    cp -v  cloudbees-core.yml cloudbees-core.yml.def
else
    #restore def
    cp -v  cloudbees-core.yml.def cloudbees-core.yml
fi


sed -e s,cloudbees-core.example.com,$DOMAIN,g < cloudbees-core.yml > tmp && mv tmp cloudbees-core.yml

diff cloudbees-core.yml.def cloudbees-core.yml



#Run the installer
kubectl apply -f cloudbees-core.yml -n $NAMESPACE
##Try helm
#cd  /Users/andreascaternberg/projects/ps-core-helm-example/
#source ./cje-install.sh $DOMAIN_NAME $SECRET_NAME

#Wait until CJOC is rolled out
kubectl rollout status sts cjoc

echo "let*s wait 60  sec for the container......"
#sleep 60
#Read the admin password
kubectl exec cjoc-0 -- cat /var/jenkins_home/secrets/initialAdminPassword
echo "open $DOMAIN/cjoc"
open "https://$ENDPOINT$DOMAIN/cjoc"

