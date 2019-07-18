This work was all done in Azure cloud shell - if you are wanting to use the CLI you will need cli packages from Azure and commands may not be copy paste. CLI walkthrough in the works.
`az aks install-cli`
***
1. Service Principle and Resource Group with Storage all need to be configured first. These are the bare minimum per: https://go.cloudbees.com/docs/cloudbees-core/cloud-install-guide/aks-install/
`az aks create --resource-group {{myResourceGroup}} --name {{myAKSCluster}} --node-count 2 --node-vm-size Standard_D4_v3 --generate-ssh-keys`

2. Get current context for Kubernetes cluster
`az aks get-credentials --resource-group {{myResourceGroup}} --name {{myAKSCluster}}`

3. Setting up Tiller BEFORE running `Helm init`
`kubectl create serviceaccount --namespace kube-system tiller`

4. Set up clusterrolebinding for tiller
`kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller`

5. Install HELM & TILLER - Azure cloud shell has both installed just need to run `Helm init` to set up Helm package manager
`helm init --service-account tiller`

6. Add Cloudbees Core Helm chart to Helm repo
`helm repo add cloudbees https://charts.cloudbees.com/public/cloudbees`

7. Create a DNS Record (Will be OperationsCenter.HostName *below*)
`cloudbees-core.example.com`

8. Install Cloudbees Core via helm with the following command
`helm install --name cloudbees-core --set OperationsCenter.HostName='{{cloudbees-core.example.com}}' --set nginx-ingress.Enabled=true --set OperationsCenter.ServiceType='ClusterIP' cloudbees/cloudbees-core`

9. After waiting 2-5 mins, go back and create an A record for your DNS from the Ingress-Controller's External IP address
`kubectl get services -n ingress-ngnix` gives you the output of the External IP from the Ingress Controller

10. You should be able to follow the instructions from the Helm install output. To see the Helm output or status of the install run `helm status cloudbees-core`

**Some things to watch out for BELOW**
***
$HELM_HOME has been configured at /home/zzimmerman/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
***

**Renaming a cluster the same name with keep Kubernetes config context, even if cluster is deleted**

**Example:**
zzimmerman@Azure:~$ `az aks get-credentials -g cloud-shell-storage-eastus -n zzManagedCluster`
A different object named zzManagedCluster already exists in your kubeconfig file.
Overwrite? (y/n): y
A different object named clusterUser_cloud-shell-storage-eastus_zzManagedCluster already exists in your kubeconfig file.
Overwrite? (y/n): y
Merged "zzManagedCluster" as current context in /home/zzimmerman/.kube/config
***
Upgrading your CloudBees Core AKS infrastructure via Helm:
helm upgrade cloudbees-core --set OperationsCenter.HostName='{{cloudbees-core.example.com}}' --set nginx-ingress.Enabled=true --set OperationsCenter.ServiceType='ClusterIP' cloudbees/cloudbees-core

Add new ip address from nginx-ingress EXTERNAL ip address to DNS records and A names.
Be patient during this process.
