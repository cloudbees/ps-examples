import com.cloudbees.opscenter.server.model.OperationsCenter

String needleMasterName = "master-1"
String newDockerImageName = "CloudBees Core - Managed Master - 2.176.3.3"

def mm = OperationsCenter
       .getInstance()
       .getConnectedMasters()
       .find { it.name==needleMasterName }

if(mm) {
   println("Updating $needleMasterName to use $newDockerImageName")
   def mmConfig = mm.configuration
   mmConfig.image = newDockerImageName
   // mmConfig provides a lot of configuration options. See the sister script in this directory for enumeration of those properties.
   mm.configuration = mmConfig
   mm.save()
   println("Saved configuration. Restarting master.")
   mm.restartAction(false) // the false here causes a graceful shutdown. Specifying true would force the termination of the pod.
}
