#!/usr/bin/env bash

yum install -y java-1.8.0-openjdk-devel

wget -O /etc/yum.repos.d/cloudbees-core-cm.repo https://downloads.cloudbees.com/cloudbees-core/traditional/client-master/rolling/rpm/cloudbees-core-cm.repo
rpm --import https://downloads.cloudbees.com/cloudbees-core/traditional/client-master/rolling/rpm/cloudbees.com.key
yum install -y cloudbees-core-cm-2.138.4.3

/etc/init.d/cloudbees-core-cm restart
