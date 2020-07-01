package com.cloudbees.opscenter.server.model
// This will only work when run against an Operations Center instance.

// WARNING
// This uses OperationsCenter classes to acheive the results desired, as well as sets default 
// that are not standard. Any use of this script requires a full understanding of what it's doing
// and how it will affect your installation.
//
// The underlying OperationsCenter classes implementation may change in future verions and render this
// obsolete and ineffective.

// Usage: `java -jar jenkins-cli.jar -auth @/path/to/secret/token -s http://jenkins.example.com/cjoc/ groovy = test-master-name < createManagedMasterWithAllConfig.groovy`

import jenkins.*
import jenkins.model.*
import hudson.*
import hudson.model.*
import com.cloudbees.masterprovisioning.kubernetes.KubernetesMasterProvisioning
import com.cloudbees.opscenter.server.model.ManagedMaster
import com.cloudbees.opscenter.server.properties.ConnectedMasterLicenseServerProperty
import com.cloudbees.opscenter.server.model.OperationsCenter

if (args.length != 1 ) {
  println "A single arg is required: masterName"
}
args.each{println it}
String masterName = args[0]


if(OperationsCenter.getInstance().getConnectedMasters().any { it?.getName()==masterName }) {
    println "Master with this name already exists."
    return
}

Map props = [
//    allowExternalAgents: false, //boolean
//    clusterEndpointId: "default", //String
//    cpus: 1.0, //Double
    disk: 5, //Integer //
//    domain: "test-custom-domain-1", //String
//    envVars: "", //String
//    fsGroup: "1000", //String
//    image: "custom-image-name", //String -- set this up in Operations Center Docker Image configuration
    javaOptions: "-XshowSettings:vm -XX:MaxRAMFraction=1 -XX:+AlwaysPreTouch -XX:+UseG1GC -XX:+ExplicitGCInvokesConcurrent -XX:+ParallelRefProcEnabled -XX:+UseStringDeduplication -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Djenkins.install.runSetupWizard=false ", //String
//    jenkinsOptions:"", //String
//    kubernetesInternalDomain: "cluster.local", //String
//    livenessInitialDelaySeconds: 300, //Integer
//    livenessPeriodSeconds: 10, //Integer
//    livenessTimeoutSeconds: 10, //Integer
    memory: 2060, //Integer
//    namespace: null, //String
//    nodeSelectors: null, //String
//    ratio: 0.7, //Double
//    storageClassName: null, //String
//    systemProperties:"", //String
//    terminationGracePeriodSeconds: 1200, //Integer
//    yaml:"" //String
]

def configuration = new KubernetesMasterProvisioning()
props.each { key, value ->
    configuration."$key" = value
}

def j = Jenkins.instance
ManagedMaster master = j.createProject(ManagedMaster.class, masterName)

println "Set config..."
master.setConfiguration(configuration)
master.properties.replace(new ConnectedMasterLicenseServerProperty(null))

println "Save..."
master.save()

println "Run onModified..."
master.onModified()

println "Provision and start..."
master.provisionAndStartAction();

