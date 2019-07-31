import com.cloudbees.masterprovisioning.kubernetes.KubernetesMasterProvisioning
import com.cloudbees.opscenter.server.properties.ConnectedMasterLicenseServerProperty;
import com.cloudbees.opscenter.server.model.ManagedMaster

def cpus, memory, disk, number_of_masters, prefix

/* Default Configuration Parameters from KubernetesMasterProvisioning
(https://github.com/cloudbees/cloud-platform-master-provisioning-plugin/blob/82b2f251927c12e28e3858cd67da0c7fcc610a51/kubernetes/src/main/java/com/cloudbees/masterprovisioning/kubernetes/KubernetesMasterProvisioning.java#L387)

disk = 50
memory = 3072
ratio = .70
cpus = 1
*/

//Configuration Parameters
cpus = 0.5
memory = 2048
disk = 2
number_of_masters = 1
name_prefix = 'master'

def ratio = 0.5
def healthCheckSeconds = 0
def begin = 1

def j = Jenkins.instance
for (int i = begin; i <= number_of_masters; i++) {
    String paddedI = String.format('%04d', i)
    ManagedMaster master = j.createProject(ManagedMaster.class, "${name_prefix}-$paddedI")
    def configuration = new KubernetesMasterProvisioning()
    configuration.cpus = cpus
    configuration.memory = memory
    configuration.ratio = ratio
    configuration.disk = disk
    master.setConfiguration(configuration)
    master.save()
    master.provisionAndStartAction()
    println(master.name)
    sleep(1000)
}
