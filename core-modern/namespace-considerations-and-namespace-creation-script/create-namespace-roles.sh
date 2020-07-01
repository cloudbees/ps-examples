#! /bin/bash

: '
# The purpose of this script is to create a namespace and the proper roles, rolebindings, and/or serviceaccounts based on user input. 
# There are two "PATHS" that can be taken which are inferred based off of user input to the script.
# 
#####################################################################################################################################
#
# PATH ONE:
#     Create a namespace for a master and force it to provision agents within the confines of that namespace. 
#
#     Command Line Options for Script --
#
#     REQUIRED:
#         -n | --namespace ## Name of the namespace
#         -m | --master-name ## Name of the master **MUST BE USED AS MASTER NAME UPON CREATION**
#         -o | --cjoc-namespace ## Namespace of CJOC -- needed for creating Cluster or Namespaced Roles and RoleBindings
#
#     Optional
#         -c | --create-clusterrole ## If this option is added to the script options on the command line, 
#                                   ## the value must be a string equaling "true" for this to take effect. 
#                                   ## Defaults to "false" if nothing is passed in
#
#               If "true", the script will create a cluster level role for CJOC (if not already created).
#               This will allow the CJOC to see and interact with ALL namespaces within the Cluster.
#               If "false", not specified, or "", then the script will create a role, rolebinding, and serviceaccount scoped to the new namespace
#
#      DO NOT USE:
#          -s | --separate-masters-agents ## Caveat: if set to "false", the script will proceed down PATH ONE
#          -a | --agent-namespace
#           
# 
#       NOTE:
#           The following snippet will still need to be added to the master provisioning YAML when creating the master in the UI 
#             (replace $namespace on line 44 with the actual namespace)
#
####################################################

apiVersion: "apps/v1"
kind: "StatefulSet"
spec:
  template:
    spec:
      serviceAccountName: "jenkins-$namespace" #REPLACE $namespace with the actual name of the namespace!!!!

####################################################
#
#
#       NOTE: 
#           You will also need to select the namespace in the UI upon master creation
#
# END PATH ONE
#
#####################################################################################################################################
#
# PATH TWO:
#     Create a namespace for agents to run within -- optionally remove the roles that allow masters to create agents in the master/cjoc namespace
#     Command Line Options for Script --
#
#     REQUIRED:
#         -s | --separate-masters-agents ## Must be set to "true" to take effect
#         -a | --agent-namespace ## Agent namespace
#         -o | --cjoc-namespace ## Namespace of CJOC -- needed for creating cluster or namespaced roles and rolebindings
#
#     Optional
#         -d | --disallow-agents-cjoc-ns ## Must be set to "true" to take effect
#
#      If the above REQUIRED options are passed into the script then PATH TWO will be followed regardless if other options are passed in
# 
#       NOTE:
#           The pod template definition -- whether at the CJOC shared cloud level, master pod template, or inline in the pipeline script -- MUST specify the Agent namespace.
#           If it does not, then the master will try to provision the agent in the CJOC/Master namespace
#
# END PATH TWO
#
#####################################################################################################################################
'


##### Functions


create_namespace()
{
    kubectl create ns $namespace
}   # end of create_namespace


create_cjoc_role_namespace()
{
    kubectl apply -f - << EOF
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: master-management-$namespace
  namespace: $namespace
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get","list","watch"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get","list","watch"]
- apiGroups: ["apps"]
  resources: ["statefulsets"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: ["extensions"]
  resources: ["ingresses"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["list"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get","list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: cjoc-master-management-binding-$namespace
  namespace: $namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: master-management-$namespace
subjects:
- kind: ServiceAccount
  name: cjoc
  namespace: $cjoc_ns
EOF
}   # end  of create_cjoc_role_namespace


create_cjoc_role_cluster()
{
    kubectl apply -f - << EOF
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: cjoc-cluster-management
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get","list","watch"]
- apiGroups: ["apps"]
  resources: ["statefulsets"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["persistentvolumeclaims"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: ["extensions"]
  resources: ["ingresses"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["list"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get","list","watch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: cjoc-cluster-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cjoc-cluster-management
subjects:
- kind: ServiceAccount
  name: cjoc
  namespace: $cjoc_ns
EOF
}   # end of create_cjoc_role_cluster


create_master_role()
{
        kubectl apply -f - << EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-$namespace
  namespace: $namespace

---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: jenkins-$namespace-access
  namespace: $namespace
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get","list","watch"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: jenkins-$namespace-view
  namespace: $namespace
subjects:
- kind: ServiceAccount
  name: jenkins-$namespace
  namespace: $namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: jenkins-$namespace-access
EOF

}   # end of create_master_role


create_master_role_agent_ns()
{
    kubectl apply -f - << EOF
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: pods-all
  namespace: $namespace
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get","list","watch"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: jenkins
  namespace: $namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pods-all
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: $cjoc_ns
EOF
}   # end of create_master_role_agent_ns


create_agent_configmap()
{
    kubectl -n $namespace apply -f - << \EOF
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: jenkins-agent
data:
  jenkins-agent: |
    #!/usr/bin/env sh

    # The MIT License
    #
    #  Copyright (c) 2015, CloudBees, Inc.
    #
    #  Permission is hereby granted, free of charge, to any person obtaining a copy
    #  of this software and associated documentation files (the "Software"), to deal
    #  in the Software without restriction, including without limitation the rights
    #  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    #  copies of the Software, and to permit persons to whom the Software is
    #  furnished to do so, subject to the following conditions:
    #
    #  The above copyright notice and this permission notice shall be included in
    #  all copies or substantial portions of the Software.
    #
    #  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    #  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    #  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    #  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    #  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    #  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    #  THE SOFTWARE.

    # Usage jenkins-slave.sh [options] -url http://jenkins [SECRET] [AGENT_NAME]
    # Optional environment variables :
    # * JENKINS_TUNNEL : HOST:PORT for a tunnel to route TCP traffic to jenkins host, when jenkins can't be directly accessed over network
    # * JENKINS_URL : alternate jenkins URL
    # * JENKINS_SECRET : agent secret, if not set as an argument
    # * JENKINS_AGENT_NAME : agent name, if not set as an argument

    if [ $# -eq 1 ]; then

        exec "$@"

    else

        # if -tunnel is not provided try env vars
        case "$@" in
            *"-tunnel "*) ;;
            *)
            if [ ! -z "$JENKINS_TUNNEL" ]; then
                TUNNEL="-tunnel $JENKINS_TUNNEL"
            fi ;;
        esac

        if [ -n "$JENKINS_URL" ]; then
            URL="-url $JENKINS_URL"
        fi

        if [ -n "$JENKINS_NAME" ]; then
            JENKINS_AGENT_NAME="$JENKINS_NAME"
        fi  

        if [ -z "$JNLP_PROTOCOL_OPTS" ]; then
            echo "Warning: JnlpProtocol3 is disabled by default, use JNLP_PROTOCOL_OPTS to alter the behavior"
            JNLP_PROTOCOL_OPTS="-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=true"
        fi

        # If both required options are defined, do not pass the parameters
        OPT_JENKINS_SECRET=""
        if [ -n "$JENKINS_SECRET" ]; then
            case "$@" in
                *"${JENKINS_SECRET}"*) echo "Warning: SECRET is defined twice in command-line arguments and the environment variable" ;;
                *)
                OPT_JENKINS_SECRET="${JENKINS_SECRET}" ;;
            esac
        fi
        
        OPT_JENKINS_AGENT_NAME=""
        if [ -n "$JENKINS_AGENT_NAME" ]; then
            case "$@" in
                *"${JENKINS_AGENT_NAME}"*) echo "Warning: AGENT_NAME is defined twice in command-line arguments and the environment variable" ;;
                *)
                OPT_JENKINS_AGENT_NAME="${JENKINS_AGENT_NAME}" ;;
            esac
        fi

        SLAVE_JAR=/usr/share/jenkins/slave.jar
        if [ ! -f "$SLAVE_JAR" ]; then
            tmpfile=$(mktemp)
            if hash wget > /dev/null 2>&1; then
                wget -O "$tmpfile" "$JENKINS_URL/jnlpJars/slave.jar"
            elif hash curl > /dev/null 2>&1; then
                curl -o "$tmpfile" "$JENKINS_URL/jnlpJars/slave.jar"
            else
                echo "Image does not include $SLAVE_JAR and could not find wget or curl to download it"
                return 1
            fi
            SLAVE_JAR=$tmpfile
        fi

        #TODO: Handle the case when the command-line and Environment variable contain different values.
        #It is fine it blows up for now since it should lead to an error anyway.

        exec java $JAVA_OPTS $JNLP_PROTOCOL_OPTS -cp $SLAVE_JAR hudson.remoting.jnlp.Main -headless $TUNNEL $URL $OPT_JENKINS_SECRET $OPT_JENKINS_AGENT_NAME "$@"
    fi
EOF
}   # end of create_agent_role


ammend_master_role_in_cjoc_ns() 
{
  kubectl apply -n $cjoc_ns -f - << EOF

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pods-all
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list","watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["get","list","watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get","list","watch"]
EOF
}   #  end of ammend_master_role_in_cjoc_ns


##### END Functions


# Instantiate Vars
namespace=
mastername=
clusterrole=
cjoc_ns=
separate_agent_and_masters=
agent_ns=
agents_disallowed=

# Loop until all parameters are used to set vars
while [ "$1" != "" ]; do
    case $1 in
        -o | --cjoc-namespace )                     shift
                                                    cjoc_ns=$1
                                                    ;;
        -s | --separate-masters-agents )            shift
                                                    separate_agent_and_masters=$1
                                                    ;;
        -d | --disallow-agents-cjoc-ns )            shift
                                                    agents_disallowed=$1
                                                    ;;
        -a | --agent-namespace )                    shift
                                                    agent_ns=$1
                                                    ;;
        -n | --namespace )                          shift
                                                    namespace=$1
                                                    ;;
        -m | --master-name )                        shift
                                                    mastername=$1
                                                    ;;
        -c | --create-clusterrole )                 shift
                                                    clusterrole=$1
                                                    ;;
    esac
    
    shift

done

# Fail if CJOC namespace is not specified -- it is needed for both paths to be successful
if [ "$cjoc_ns" = "" ]; then
    echo "ERROR! Please specify the CJOC namespace and try again"
    exit 1
fi

# PATH TWO:
#   MASTERS AND CJOC IN ONE NAMESPACE, AGENTS IN ANOTHER -- OPTION TO REMOVE ABILITY OF MASTERS TO PROVISION AGENTS IN MASTER/CJOC NAMESPACE
#       If separate_agent_and_masters is not empty and is true
#       and agent_ns is not empty, then we are assume that we are simply creating an agent namespace to separate masters/cjoc from agents
if [ "$separate_agent_and_masters" != "" ] && [ "$separate_agent_and_masters" = "true" ] && [ "$agent_ns" != "" ]; then
    echo ""
    echo "***********************************************"
    echo ""
    echo "Creating agent namespace and giving masters ability to create agents there:"
    namespace=$agent_ns
    create_namespace
    echo ""
    echo "Create roles for agent namespace:"
    create_master_role_agent_ns
    echo ""
    echo "Create agent configmap:"
    create_agent_configmap
    echo ""

    if [ "$agents_disallowed" != "" ] && [ "$agents_disallowed" = "true" ]; then
      echo "Removing ability of masters to provision agents in CJOC/Master Namespace:"
      ammend_master_role_in_cjoc_ns
      echo ""
    fi

    echo "***********************************************"

    exit 0
fi

# PATH ONE:
#   MASTERS AND ASSOCIATED AGENTS IN SAME NAMESPACES, SEPARATE FROM OTHER MASTERS AND AGENTS
#
#       Make sure namespaces and master name were passed in
if [ "$namespace" = "" ]; then
    echo "FAIL! Please specify a namespace and run again"
    exit 1
fi

if [ "$mastername" = "" ]; then
    echo "ERROR! Please specify the name of the master and run again"
    exit 1
fi

echo ""
echo "***********************************************"
echo ""
echo "Creating master and agent namespace, giving CJOC ability to create masters, and the masters the ability to create agents:"
create_namespace

if [ "$clusterrole" = "" ] || [ "$clusterrole" = "false" ]; then
    echo ""
    echo "Create Cluster Role not specified -- creating namespace specific roles in namespace $namespace:"
    create_cjoc_role_namespace
    echo ""
else
    echo ""
    echo "Create Cluster Role specified -- CJOC has access to ALL namespaces:"
    create_cjoc_role_cluster
    echo ""
fi

echo ""
echo "Create master role in the namespace so it can create agents:"
create_master_role
echo ""
echo "Create agent configmap in the master namespace:"
create_agent_configmap
echo ""
echo "***********************************************"

exit 0