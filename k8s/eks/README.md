
scripts to setup a k8s cluster in GKE
For further information see see https://go.cloudbees.com/docs/cloudbees-core/cloud-install-guide/gke-install/#prerequisites  

A google account is required

Usage:


#initialize user, roles, perms
```
./00-init.sh
```


#Create a cluster

```
./01-cluster-create.sh
```

#delete a cluster

```
./02-cluster-delete.sh
```

#scale down

```
./02-cluster-scale-down.sh
```

#Create Ingress

```
./03-create-ingress.sh
```






