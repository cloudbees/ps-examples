
scripts to setup a k8s cluster in GKE
For further information see see https://go.cloudbees.com/docs/cloudbees-core/cloud-install-guide/gke-install/#prerequisites  

A google account is requzired

Usage:

#Create a cluster

```
./01-create-cluster.sh
```

#Connect to a cluster

```
./02-cluster-connect.sh
```

#Create SA

```
./02-cluster-create-service-account.sh
```

#Create Ingress

```
./03-cluster-create-ingress.sh
```






