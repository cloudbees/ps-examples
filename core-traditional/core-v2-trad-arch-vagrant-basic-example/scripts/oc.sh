#!/usr/bin/env bash

yum install -y java-1.8.0-openjdk-devel

wget -O /etc/yum.repos.d/cloudbees-core-oc.repo https://downloads.cloudbees.com/cloudbees-core/traditional/operations-center/rolling/rpm/cloudbees-core-oc.repo
rpm --import https://downloads.cloudbees.com/cloudbees-core/traditional/operations-center/rolling/rpm/cloudbees.com.key
yum install -y cloudbees-core-oc-2.138.4.3

/etc/init.d/cloudbees-core-oc restart
