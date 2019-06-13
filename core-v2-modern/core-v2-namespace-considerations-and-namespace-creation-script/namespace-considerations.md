

# Namespace Considerations

## Issue

 *  How should I architect my cluster to most effectively use namespaces to isolate my resources?
 *  What are the pros/cons of different namespace architectures? 
 *  What steps do I need to take to implement these different architectures?

## Environments

* [CloudBees Core](https://release-notes.cloudbees.com/product/140)
* [CloudBees Core for Modern Cloud Platforms - Managed Master](https://release-notes.cloudbees.com/product/141)
* [CloudBees Core for Modern Cloud Platforms - Operations Center](https://release-notes.cloudbees.com/product/142)

## Different Types of Architectures to Consider with CloudBees Core v2

### All in One Architecture

* CJOC, Masters, and agents all run in the same namespace
  * PROS:
    1. Easy to implement
    2. Works "out of the box" -- no additional configuration necessary
  * CONS:
    1. No ability to specify resource quotas/limitations for different masters or agents
    2. May not be secure enough for some organizations
    3. Charge-back becomes harder

### CJOC and Masters One, Agents in Another

* CJOC and all Masters run in the same namespace, Agents run in a separate namespace
  * PROS:
    1. Ability to create resource quotas/limitations on agent or CJOC/Master namespace
    2. Easily supported in Core by provisioning 1 more namespace for builds, 1 service account to start pods in that namespace, and configuring the shared cloud to use that namespace and serviceaccount (**VERIFICATION NEEDED**)
    3. 
  * CONS:
    1. Additional configuration is necessary on the Kubernetes side (creation of specific roles, rolebindings, and --in some cases-- serviceaccounts) needs to take place to ensure that this works as expected
    2. Additional configuration is necessary in the pod template configurations at the CJOC/shared-cloud level, master pod template level, or in the Jenkinsfile/pipeline script where the agent pod template is defined
       * For example, you must specify the namespace and the serviceaccount in the pod template. (**VERIFICATION NEEDED**)
    3. The only way to ensure that agents cannot be launched in the CJOC/Master namespace is to remove some of the rules that are created by default when the cloudbees-core.yaml installer is used to create the CloudBeesd Core v2 objects. **HOWEVER**, if this is done, but a pod template is not configured with the correct namespace then the master will try to provision an agent in the CJOC/Master namespace and the job will stay in a pending state ad infinitum, waiting for an executor to on which to run. This can lead to unexpected results of jobs and strange states within the master. 


### CJOC isolated, Masters and Agents run together

#### With Cluster-level Permissions

* CJOC runs in its own namespace and all masters run in their own namespace with their associated agents. CJOC is bound to a ClusterRole with permissions to see and manipulate EVERYTHING in ALL namespaces.
  * PROS:
    1. The ClusterRole and ClusterRoleBinding make it very easy to create masters.
    2. Allows to easily separate resources between teams and track which masters are utilizing the most resources.
    3. Keeps a "build storm" kicked off by one master from affecting the ability of other masters to perform builds.
    4. Greatest control over each team's resource limits
  * CONS:
    1. Giving the ability for the CJOC service account to see and manipulate EVERYTHING in ALL namespaces may not work in all cases from a security perspective, especially if there are other production applications running within the cluster.
        * If CloudBees Core v2 is the only application running in the cluster, then it may be acceptable.

#### With Namespace-level Permissions

* CJOC runs in its own namespace and all masters run in their own namespace with their associated agents. CJOC is bound to a Role with permissions to see and manipulate objects in each namespace created for masters and their agents.
  * PROS:
    1. Ensures that the CJOC serviceaccount only has access to the namespaces and objects that it *should* have access to.
    2. Allows to easily separate resources between teams and track which masters are utilizing the most resources.
    3. Greatest control over each team's resource limits
    4. Keeps a "build storm" kicked off by one master from affecting the ability of other masters to perform builds.
  * CONS:
    1. More steps necessary to implement than when CJOC is given cluster level permissions.

#### Adding Team Masters to Separate Namespaces

While it *is* possible to create Team Masters in custom namespaces, it necessitates that additional, manual steps be taken before the Team Master is created. For this to work, you must:

* Navigate to the `Manage Jenkins` > `Configure System` page of CJOC and look for the `Kubernetes Master Provisioning` section of that page.
* Once there, change the `Namespace` you would like to use for the Team Master, click Validate, and Save
* Then create your Team Master and verify that it came up in the proper namespace
* If you do not set the `Namespace` field on that page to something else or to blank, then Team Masters and Managed Masters that do not have a custom namespace defined will be automatically  created there.

### Summary

It should be noted that there is not a "one-size-fits-all" solution and the right decision as far as namespace architecture goes should be left in the hands of the owners of the cluster. For additional resources on namespace architecture, RBAC, and other topics, please review the links in the following resources section.

##### Resources:

* [Kubernetes and RBAC: Restrict User Access To One Namespace](https://jeremievallee.com/2018/05/28/kubernetes-rbac-namespace-user.html) for a good blog post on K8s Namespaces and RBAC
* [Google Group Discussion about RBAC](https://groups.google.com/forum/#!topic/kubernetes-sig-auth/HMc5WZP9pks)
* [Kubernetes Plugin](https://github.com/jenkinsci/kubernetes-plugin) for examples and additional information on how to configure pod templates
* [Interesting Posts about "Failing" at Kubernetes](https://k8s.af/)
