// This will only work when run against an Operations Center instance.

import com.cloudbees.masterprovisioning.kubernetes.KubernetesMasterProvisioning
import com.cloudbees.opscenter.server.model.ManagedMaster
import hudson.*
import hudson.model.*
import jenkins.*
import jenkins.model.*

def props = [
        "allowExternalAgents",
        "clusterEndpointId",
        "cpus",
        "disk",
        "domain",
        "envVars",
        "fsGroup",
        "image",
        "imagePullSecrets",
        "javaOptions",
        "jenkinsOptions",
        "kubernetesInternalDomain",
        "livenessInitialDelaySeconds",
        "livenessPeriodSeconds",
        "livenessTimeoutSeconds",
        "memory",
        "namespace",
        "nodeSelectors",
        "ratio",
        "storageClassName",
        "systemProperties",
        "terminationGracePeriodSeconds",
        "yaml",
        "dockerImage",
        "computedSystemProperties",
]

def allMMs = Jenkins.get().getAllItems(ManagedMaster.class)

allMMs.each { managedMaster ->
    println ""
    println "${managedMaster.displayName} (idName: ${managedMaster.idName})"
    println "-------------------"

    KubernetesMasterProvisioning kmp = (KubernetesMasterProvisioning) managedMaster.getConfiguration();

    props.each {
        def value = kmp?."$it"
        println "$it: $value"
    }

    def state = managedMaster.getState()
    println("state: $state")

    println "validActionSet:" + managedMaster.getValidActionSet()
}
