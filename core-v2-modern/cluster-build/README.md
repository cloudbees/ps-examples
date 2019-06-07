

# cluster-build

The example shows how to use a bash script build a cluster called test-jenkins-cje that runs cloudbees-cloud-core-oc *2.138.4.3*.  This cluster is deployed in gcloud and this example assumes that the environment is configured to use gcloud and kubectl.

*Note:* *2.138.4.3* is the version used because it was release before a bug was introduced making it harder to add teams.  This version is assumed to be the used version for this documentation.

## Noted adjustments made in this cluster configuration.

* The deployment process requires adding variables during runtime, cloudees-core.yml is the rendered result of this action.  The file will be over-written each time the script gcloud_deployment.sh is run.  To make changes to the settings defined in the file, edit the template file templates/cloudbees-core.tpl instead.

* In order to overcome a timeout issue that occurs when over 800 team masters are added to the cluster, the following annotations were added to the cjoc ingress:

```
nginx.ingress.kubernetes.io/proxy-connect-timeout: "3600"
nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
```

These can be found on lines 185 to 187 in the cloudbees-core template.

## Building the cluster.

Run the script

```
./gcloud_deployment.sh
```

The output should look similar to:

```
WARNING: Starting in 1.12, new clusters will have basic authentication disabled by default. Basic authentication can be enabled (or disabled) manually using the `--[no-]enable-basic-auth` flag.
WARNING: Starting in 1.12, new clusters will not have a client certificate issued. You can manually enable (or disable) the issuance of the client certificate using the `--[no-]issue-client-certificate` flag.
WARNING: Currently VPC-native is not the default mode during cluster creation. In the future, this will become the default mode and can be disabled using `--no-enable-ip-alias` flag. Use `--[no-]enable-ip-alias` flag to suppress this warning.
WARNING: Starting in 1.12, default node pools in new clusters will have their legacy Compute Engine instance metadata endpoints disabled by default. To create a cluster with legacy instance metadata endpoints disabled in the default node pool, run `clusters create` with the flag `--metadata disable-legacy-endpoints=true`.
This will enable the autorepair feature for nodes. Please see https://cloud.google.com/kubernetes-engine/docs/node-auto-repair for more information on node autorepairs.
WARNING: Starting in Kubernetes v1.10, new clusters will no longer get compute-rw and storage-ro scopes added to what is specified in --scopes (though the latter will remain included in the default --scopes). To use these scopes, add them explicitly to --scopes. To use the new behavior, set container/new_scopes_behavior property (gcloud config set container/new_scopes_behavior true).
Creating cluster add-teams-test in us-east4... Cluster is being health-checked (master is healthy)...done.                                                                                                                                                                   
Created [https://container.googleapis.com/v1/projects/performance-testing-234416/zones/us-east4/clusters/add-teams-test].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/us-east4/add-teams-test?project=performance-testing-234416
kubeconfig entry generated for add-teams-test.
NAME            LOCATION  MASTER_VERSION  MASTER_IP     MACHINE_TYPE    NODE_VERSION   NUM_NODES  STATUS
add-teams-test  us-east4  1.11.7-gke.12   35.194.74.63  custom-8-53248  1.11.7-gke.12  9          RUNNING
storageclass.storage.k8s.io "ssd" created
storageclass.storage.k8s.io "standard" patched
storageclass.storage.k8s.io "ssd" patched
clusterrolebinding.rbac.authorization.k8s.io "cluster-admin-binding" created
namespace "ingress-nginx" created
configmap "nginx-configuration" created
configmap "tcp-services" created
configmap "udp-services" created
serviceaccount "nginx-ingress-serviceaccount" created
clusterrole.rbac.authorization.k8s.io "nginx-ingress-clusterrole" created
role.rbac.authorization.k8s.io "nginx-ingress-role" created
rolebinding.rbac.authorization.k8s.io "nginx-ingress-role-nisa-binding" created
clusterrolebinding.rbac.authorization.k8s.io "nginx-ingress-clusterrole-nisa-binding" created
deployment.apps "nginx-ingress-controller" created
service "ingress-nginx" created
namespace "cje" created
namespace "cje" labeled
Context "gke_performance-testing-234416_us-east4_add-teams-test" modified.
serviceaccount "cjoc" created
role.rbac.authorization.k8s.io "master-management" created
rolebinding.rbac.authorization.k8s.io "cjoc" created
configmap "cjoc-configure-jenkins-groovy" created
statefulset.apps "cjoc" created
service "cjoc" created
ingress.extensions "cjoc" created
serviceaccount "jenkins" created
role.rbac.authorization.k8s.io "pods-all" created
rolebinding.rbac.authorization.k8s.io "jenkins" created
configmap "jenkins-agent" created
Waiting for 1 pods to be ready...
statefulset rolling update complete 1 pods at revision cjoc-9775565f4...
eb7e5266a4b64a6cbad762cee2efb905
http://jenkins.35.245.23.48.xip.io/cjoc/login?from=%2Fcjoc%2F
service "cjoc-jnlp" created
configmap "tcp-services" configured
deployment.apps "nginx-ingress-controller" scaled
```

Note the URL of the newly created CJOC and the string about it, which will be the default admin password you will need to log into the cluster.
