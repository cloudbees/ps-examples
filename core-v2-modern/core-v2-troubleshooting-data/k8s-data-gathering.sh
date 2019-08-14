#! /bin/bash

: '
This script gathers a snapshot of data from a specific cluster, tests the connections between one or more masters and CJOC, and gets the support bundles from CJOC and one or more masters. 

It can be targeted at a specific master by passing in the following required fields:

-c CJOC_NAMESPACE
-m MASTER_NAMESPACE -- if no value is passed in, the var will be set to the CJOC_NAMESPACE
-n MASTER_NAME

It can also be targeted at a set of masters by passing in a mapping file that is a CSV where column one is the master name and column two is the master namespace. It should be in this format:

```
master-name1,master-namespace1
master-name2,master-namespace2
master-name3,master-namespace3
```

For this to work, the -c CJOC_NAMESPACE will still need to be passed in to the script.



######## TO DO --

* Testing needs to be done for masters with spaces in their name -- likely will cause some parts of the script to break
* It may be worthwhile to add a section in to test service accounts to see if they have the capabilities to do all of the "things" necessary to make CloudBees Core work


'

##### Functions

gather_data_initial()
{
    mkdir core-modern-data && cd core-modern-data
    kubectl get node -o yaml > node.yaml
    kubectl cluster-info dump --output-directory=./cluster-state/
    cd cluster-state
    kubectl cluster-info > 000-cluster-info.txt
    cd ..
    mkdir cjoc && cd cjoc
    kubectl cp cjoc-0:/var/jenkins_home/support/ ./cjoc-support/ -n $cjoc_namespace
    kubectl get pod,svc,endpoints,statefulset,ingress,pvc,pv,sa,role,rolebinding -o wide -n $cjoc_namespace > $cjoc_namespace-objects.txt
    kubectl exec -ti cjoc-0 curl localhost:50000 -n $cjoc_namespace > 001-cjoc-curl-local-5000.txt

    namespace=$cjoc_namespace

    get_yaml
    cd ..
    
}   # end of create_namespace

gather_data_from_mapping_file(){
    for line in $(<$mapping_file)
    do
        IFS=',' read -r -a array <<< "$line"
        master_name="${array[0]}"
        master_namespace="${array[1]}"
        namespace=$master_namespace
        mkdir $master_name && cd $master_name
        get_yaml
        connection_tests
        cd ..
    done
}

get_yaml(){

    IFS=',' read -r -a array <<< "pod,statefulset,svc,endpoints,ingress,pvc,pv,sa,role,rolebinding"
    for element in "${array[@]}"
    do  
        kubectl get $element -o yaml -n $namespace > $element-$namespace.yaml 
    done
}

connection_tests(){
    mkdir connection-tests &&  cd connection-tests
    kubectl exec -ti $master_name-0 -n $master_namespace curl cjoc.$cjoc_namespace.svc.cluster.local:50000 > $master_name-curl-cjoc-5000.txt
    kubectl exec -ti $master_name-0 -n $master_namespace curl $(kubectl get svc cjoc -n $cjoc_namespace -o jsonpath='{.spec.clusterIP}'):50000 > $master_name-curl-cjoc-ip-50000.txt
    kubectl exec -ti cjoc-0 -n $cjoc_namespace curl http://$master_name.$master_namespace.svc.cluster.local/$master_name/ > cjoc-curl-$master_name.txt
    kubectl exec -ti $master_name-0 -n $master_namespace curl http://cjoc.$cjoc_namespace.svc.cluster.local/cjoc/ > $master_name-curl-cjoc-txt
    kubectl exec -ti cjoc-0 -n $cjoc_namespace curl http://$(kubectl get svc $master_name -n $master_namespace -o jsonpath='{.spec.clusterIP}')/$master_name/ > cjoc-curl-$master_name-ip.txt
    kubectl exec -ti $master_name-0 -n $master_namespace curl http://$(kubectl get svc cjoc -n $cjoc_namespace -o jsonpath='{.spec.clusterIP}')/cjoc/ > $master_name-curl-cjoc-ip.txt
    cd ..
    kubectl cp $master_name-0:/var/jenkins_home/support/ ./$master_name-support/ -n $master_namespace
}
##### END Functions


# Instantiate Vars
cjoc_namespace=
master_name=
master_namespace=
mapping_file=

# Loop until all parameters are used to set vars
while [ "$1" != "" ]; do
    case $1 in
        -c | --cjoc-namespace )                     shift
                                                    cjoc_namespace=$1
                                                    ;;
        -m | --master-namespace )                   shift
                                                    master_namespace=$1
                                                    ;;
        -n | --master-name )                        shift
                                                    master_name=$1
                                                    ;;
        -f | --file )                               shift
                                                    mapping_file=$1
                                                    ;;
    esac
    
    shift

done

if [ "$cjoc_namespace" = "" ]; then
    echo "ERROR: missing required field. Please pass in CJOC namespace value with '-c NAMESPACE' or '--cjoc-namespace NAMESPACE'"
    exit 1
fi

if [ "$mapping_file" != "" ]; then
    if [ ! -f "$mapping_file" ]; then
        echo "$mapping_file does not resolve to a valid file"
        exit 1
    fi

    gather_data_initial
    gather_data_from_mapping_file

    exit 0

else
    if [ "$cjoc_namespace" = "" ] || [ "$master_name" = "" ]; then
        echo "Without mapping file, please pass in required fields:"  
        echo "  '-c' or '--cjoc-namespace'" 
        echo "  '-n' or '--master-name'"
        exit 1
    fi
    if [ "$master_namespace" = "" ]; then
        master_namespace=$cjoc_namespace
    fi

    gather_data_initial
    namespace=$master_namespace
    get_yaml
    connection_tests

fi


exit 0
