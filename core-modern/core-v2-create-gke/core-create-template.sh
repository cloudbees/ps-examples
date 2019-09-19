#!/usr/bin/env sh

export CLUSTER_NAME="cluster-name-here"
# export CLUSTER_VERSION="1.13.7-gke.8" # not required, will use latest version if not specified
export GCLOUD_PROJECT="your-project-here"
export GCLOUD_ZONE="us-central1-a" #currently only zones, probably easily refactored to allow region-based deployment
export OWNER_LABEL="your-username" # user to label cluster and dns so we know who to call in the middle of the night
export MACHINE_TYPE="n1-standard-2"
export MACHINE_DISK_SIZE=20
export NUMBER_OF_NODES=2
export CB_CORE_NAMESPACE="cloudbees-core"

export MANAGED_ZONE_NAME="gcp-dns-managed-zone-name"
export BASE_DOMAIN="gcp.example.com"
export SUBDOMAIN=$CLUSTER_NAME # this is just for a sane default, but you can change this to whatever

export CB_CORE_CHART_VERSION=2.176.203
export HELM_RELEASE_NAME="cloudbees-core"

./create-core-v2-gke

