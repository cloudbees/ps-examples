#!/usr/bin/env bash

export CB_VERSION=2.176.1.4
CB_ARCHIVE="cloudbees-core_${CB_VERSION}_kubernetes.tgz"
#https://downloads.cloudbees.com/cloudbees-core/cloud/latest/
#https://downloads.cloudbees.com/cloudbees-core/cloud/latest/cloudbees-core_2.176.1.4_kubernetes.tgz
rm $CB_ARCHIVE
rm -Rf ${CB_ARCHIVE%%.tgz}
curl https://downloads.cloudbees.com/cloudbees-core/cloud/${CB_VERSION}/$CB_ARCHIVE -o ./$CB_ARCHIVE
tar -xvzf $CB_ARCHIVE
ln -s ${CB_ARCHIVE%%.tgz} cloudbees-core

