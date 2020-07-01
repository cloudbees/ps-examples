import com.cloudbees.hudson.plugins.folder.*
import com.cloudbees.hudson.plugins.modeling.impl.builder.BuilderTemplate
import com.cloudbees.hudson.plugins.modeling.impl.folder.FolderTemplate
import com.cloudbees.hudson.plugins.modeling.impl.jobTemplate.JobTemplate
import com.cloudbees.hudson.plugins.modeling.impl.auxiliary.AuxModel
import jenkins.branch.OrganizationFolder
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.multibranch.*
import java.util.concurrent.TimeUnit

VIOLATION_NO_LOG_ROTATION = "NO LOG ROTATION"
VIOLATION_INCORRECT_LOG_ROTATION = "INCORRECT LOG ROTATION"
VIOLATION_NEVER_EXECUTED = "NEVER EXECUTED"
VIOLATION_NO_RECENT_BUILDS = "NO RECENT BUILDS"
VIOLATION_EMPTY_FOLDER="EMPTY FOLDER"
VIOLATION_TOO_MANY_BUILDS="TOO MANY BUILDS"
VIOLATION_PREVIOUSLY_FLAGGED="NOT CORRECTED SINCE PREVIOUS AUDIT"

DAYS_TO_KEEP_BUILDS = 180
NUM_TO_KEEP= 20
DAYS_TO_KEEP_JOB = 365
getJobs=true

def processFolder(Item folder) {
    def violations = []
    if (!(folder.getFullName().contains("origami"))){
    folder.getItems().each {
        if (it instanceof Folder) {
        if(it.getItems().size()>0){
        violations += processFolder(it)
        } //if size is greater than zero
         else {
         def jobDescription=it.getDescription()

         if ((jobDescription==null)||(!(jobDescription.contains("This job/folder does not meet corporate standards")))){
               violations += [["kind": VIOLATION_EMPTY_FOLDER,"job": it.getFullName()]]}
            else{
            if (jobDescription.contains("This job/folder does not meet corporate standards"))
            {
               violations += [["kind": VIOLATION_PREVIOUSLY_FLAGGED,"job": it.getFullName()]]
            }
            }
              }// folder size is 0
        } else if (it instanceof OrganizationFolder || it instanceof WorkflowMultiBranchProject) {
            violations += processSpecialFolder(it)
        } else {
            violations += processJob(it)
        }
    }
    }// skip the origami folder
    return violations
}


def processSpecialFolder(Item folder) {
    def violations = []
    if( folder.orphanedItemStrategy.daysToKeep > DAYS_TO_KEEP_BUILDS.toInteger() ||folder.orphanedItemStrategy.numToKeep >NUM_TO_KEEP.toInteger()){
      violations += [["kind": VIOLATION_INCORRECT_LOG_ROTATION,"job": folder.getFullName()]]}
folder.getItems().each {
    if (it instanceof OrganizationFolder || it instanceof WorkflowMultiBranchProject) {
        it.getItems().each{
    if (it.builds.size()>NUM_TO_KEEP.toInteger()){
        violations += [["kind": VIOLATION_TOO_MANY_BUILDS,"job": it.getFullName()]]
        }
        }//end it each
}//end if it is org
}// end folder each
    return violations
}

def processJob(Item job) {
    def violations = []
    def jobDescription=job.getDescription()
    if (job instanceof FolderTemplate || job instanceof JobTemplate|| job instanceof AuxModel || job instanceof ExternalJob || job instanceof BuilderTemplate||job.getName().contains("PR-")||job.getName()=="Chef-master-seed"||job.getName()=="Chef-Remote-Factory"||job.getName()=="Import_Job_From_J1_to_J2"||job.getName()=="Create_Admin_Group"||job.getName()=="Create_Admin_Group"||job.getName()=="Examples"||job.getName()=="Chef_Search"||job.getName()=="Chef_Upload"||job.getName()=="Chef_node_cleanup"||job.getName()=="Node_Search"||job.getName()=="Non-Prod_Community_cookbooks"||job.getName()=="Non-Prod_self_service_delete_nodes"||job.getName()=="Prod_Chef_Push_Job"||job.getName()=="Prod_Community_cookbooks"||job.getName()=="Prod_self_service_delete_nodes") {
            return violations
    }
    if (!(job.isBuildable())&& (!(jobDescription==null)))
    { if (jobDescription.contains("This job/folder does not meet corporate standards"))
    {
      violations += [["kind": VIOLATION_PREVIOUSLY_FLAGGED,"job": job.getFullName()]]
    }
    }
    if (job.isBuildable() && job.supportsLogRotator() && job.getProperty(jenkins.model.BuildDiscarderProperty) == null) {
        violations += [["kind": VIOLATION_NO_LOG_ROTATION,"job": job.getFullName()]]
    } else {
    if (job.logRotator && (job.logRotator.daysToKeep > DAYS_TO_KEEP_BUILDS.toInteger()||job.logRotator.daysToKeep==-1)||(job.logRotator && (job.logRotator.numToKeep > NUM_TO_KEEP.toInteger()||job.logRotator.numToKeep==-1)))  {
            violations += [["kind": VIOLATION_INCORRECT_LOG_ROTATION,"job": job.getFullName()]]
        }
    }

    if(job.nextBuildNumber == 1) {
        def file = job.getConfigFile().getFile();
        def modified_in_seconds = TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis() - file.lastModified())
        def modified_in_days = TimeUnit.SECONDS.toDays(modified_in_seconds)
    if(modified_in_days > DAYS_TO_KEEP_JOB) {
         if ((jobDescription==null)||(!(jobDescription.contains("This job/folder does not meet corporate standards")))) {
           violations += [["kind": VIOLATION_NEVER_EXECUTED,"job": job.getFullName()]]
      }
    }// modified greater days to keep
    }

    def lastBuild = job.getLastBuild()
    if(lastBuild) {
        def last_build_in_seconds = TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis() - lastBuild.getTime().getTime())
        def lastbuild_in_days = TimeUnit.SECONDS.toDays(last_build_in_seconds)
     if(lastbuild_in_days > DAYS_TO_KEEP_JOB) {
       if ((jobDescription==null)||(!(jobDescription.contains("This job/folder does not meet corporate standards")))){
         violations += [["kind": VIOLATION_NO_RECENT_BUILDS,"job": job.getFullName()]]
       }
      }// last build greater days to keep
    }//last build
    if (job.builds.size()>NUM_TO_KEEP.toInteger()){
            violations  += [["kind": VIOLATION_TOO_MANY_BUILDS,"job": job.getFullName()]]}

    return violations
}

def violations = []
Jenkins.instance.getItems().each {
    if (it instanceof Folder) {
        violations += processFolder(it)
    } else if (it instanceof OrganizationFolder || it instanceof WorkflowMultiBranchProject) {
        violations += processSpecialFolder(it)
    } else {
        violations += processJob(it)
    }
}

violations_by_kind = [:]
violations_by_kind.put("EMPTY FOLDER",0)
violations_by_kind.put("INCORRECT LOG ROTATION",0)
violations_by_kind.put("NO LOG ROTATION",0)
violations_by_kind.put("NO RECENT BUILDS",0)
violations_by_kind.put("NEVER EXECUTED",0)
violations_by_kind.put("TOO MANY BUILDS",0)
violations_by_kind.put("NOT CORRECTED SINCE PREVIOUS AUDIT",0)
violations.each {
    if(violations_by_kind[it["kind"]] == null) {
        violations_by_kind[it["kind"]] = 0
    }
    violations_by_kind[it["kind"]]++
}

def sortedkind=violations_by_kind.sort()
if (!(getJobs)){
sortedkind.eachWithIndex { kind,count,i ->
  print "${count} "
  }
  }
  else{
  def sortedViolations=violations.sort{it.kind}
  sortedViolations.each {
    println ",${it.kind},${it.job}"
    }
  }
return;
