#!/bin/sh

DOMAIN_NAME=$1  # URL of the Jenkins Modern Cluster.
USERNAME=$2     # USERNAME of an existing user setup on the Jenkins OC.
TOKEN=$3        # API TOKEN of the USERNAME.

# This bash script requires that following applications to be installed available in path.
# * java
# * jenkins-cli.jar
# Not having the above installed will prevent successful execution.


java \
  -jar jenkins-cli.jar  \
    -s http://$DOMAIN_NAME/cjoc \
    -p 50000 \
    -noKeyAuth \
    -auth $USERNAME:$TOKEN \
    list-masters | jq "."
    #create-job 'louiecorbo2' < jobs/louiecorbo.xml #| jq "."
