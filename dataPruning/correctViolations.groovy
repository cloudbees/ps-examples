import com.cloudbees.hudson.plugins.folder.*
import com.cloudbees.hudson.plugins.modeling.impl.builder.BuilderTemplate
import com.cloudbees.hudson.plugins.modeling.impl.folder.FolderTemplate
import com.cloudbees.hudson.plugins.modeling.impl.jobTemplate.JobTemplate
import com.cloudbees.hudson.plugins.modeling.impl.auxiliary.AuxModel
import jenkins.branch.OrganizationFolder
import jenkins.model.Jenkins
import org.jenkinsci.plugins.workflow.multibranch.*
import java.util.concurrent.TimeUnit
import groovy.transform.Field


VIOLATION_NO_LOG_ROTATION = "NO LOG ROTATION"
VIOLATION_INCORRECT_LOG_ROTATION = "INCORRECT LOG ROTATION"
VIOLATION_NEVER_EXECUTED = "NEVER EXECUTED"
VIOLATION_NO_RECENT_BUILDS = "NO RECENT BUILDS"
VIOLATION_EMPTY_FOLDER="EMPTY FOLDER"
VIOLATION_TOO_MANY_BUILDS="TOO MANY BUILDS"
VIOLATION_PREVIOUSLY_FLAGGED="NOT CORRECTED SINCE PREVIOUS AUDIT"

DAYS_TO_KEEP_BUILDS = 180
NUM_TO_KEEP= 20
DAYS_TO_KEEP_JOB = 180

@Field def cleanedJobsTotal = 0
cleanedJobsLimit = 2
cleanJobList = []
def deletion= new Date() + 90
reasonForDisable="<b>This job/folder does not meet corporate standards, and will be deleted after ${deletion}</b>"
def temp= 0
def delList = []
//dryRun=false

def processFolder(Item folder) {
    def cleanJobList = []
    if (!(folder.getFullName().contains("origami"))){
    folder.getItems().each {
        if (it instanceof Folder) {
           if(it.getItems().size()>0){
            cleanJobList += processFolder(it)}
            else {
               def jobDescription=it.getDescription()
               if ((jobDescription==null)||(!(jobDescription.contains("This job/folder does not meet corporate standards")))){
                 cleanJobList += [["kind": VIOLATION_EMPTY_FOLDER,"job": it.getFullName()]]}
              else
              if (jobDescription.contains("This job/folder does not meet corporate standards"))
              {
              cleanJobList += [["kind": VIOLATION_PREVIOUSLY_FLAGGED, "job": it.getFullName()]]
               }
                 }// if folder size greater 0
                 }// if it is Folder
            else if (it instanceof OrganizationFolder || it instanceof WorkflowMultiBranchProject) {
                     cleanJobList += processSpecialFolder(it)}
      else {
            cleanJobList += processJob(it)
        }
    }// end each
      }// skip the origami folder
    return cleanJobList
}


def processSpecialFolder(Item folder) {
      def cleanJobList=[]
        if( folder.orphanedItemStrategy.daysToKeep > DAYS_TO_KEEP_BUILDS.toInteger() ||folder.orphanedItemStrategy.numToKeep >NUM_TO_KEEP.toInteger()){
          cleanJobList += [["kind": VIOLATION_INCORRECT_LOG_ROTATION,"job": folder.getFullName()]]}
    folder.getItems().each {
        if (it instanceof OrganizationFolder || it instanceof WorkflowMultiBranchProject) {
        it.getItems().each{
    if (it.builds.size()>NUM_TO_KEEP.toInteger()){
            cleanJobList += [["kind": VIOLATION_TOO_MANY_BUILDS,"job": it.getFullName()]]}
            }//end it each
    }//end if it is org
    }// end folder each
    return cleanJobList
}

def processJob(Item job) {
    def cleanJobList = []
    def jobDescription=job.getDescription()
    if (job instanceof FolderTemplate || job instanceof JobTemplate|| job instanceof AuxModel || job instanceof ExternalJob || job instanceof BuilderTemplate||job.getName().contains("PR-")||job.getName()=="Chef-master-seed"||job.getName()=="Chef-Remote-Factory"||job.getName()=="Import_Job_From_J1_to_J2"||job.getName()=="Create_Admin_Group"||job.getName()=="Create_Admin_Group"||job.getName()=="Examples"||job.getName()=="Chef_Search"||job.getName()=="Chef_Upload"||job.getName()=="Chef_node_cleanup"||job.getName()=="Node_Search"||job.getName()=="Non-Prod_Community_cookbooks"||job.getName()=="Non-Prod_self_service_delete_nodes"||job.getName()=="Prod_Chef_Push_Job"||job.getName()=="Prod_Community_cookbooks"||job.getName()=="Prod_self_service_delete_nodes") {
        return cleanJobList
    }
    if (!(job.isBuildable())&& (!(jobDescription==null)))
    { if (jobDescription.contains("This job/folder does not meet corporate standards"))
    {
      cleanJobList += [["kind": VIOLATION_PREVIOUSLY_FLAGGED,"job": job.getFullName()]]
    }
    }
    else
    {
    if (job.isBuildable() && job.supportsLogRotator() && job.getProperty(jenkins.model.BuildDiscarderProperty) == null) {
       cleanJobList += [[ "kind": VIOLATION_NO_LOG_ROTATION,"job": job.getFullName()]]
    } else {
        if (job.logRotator && (job.logRotator.daysToKeep > DAYS_TO_KEEP_BUILDS.toInteger()||job.logRotator.daysToKeep==-1)||(job.logRotator && (job.logRotator.numToKeep > NUM_TO_KEEP.toInteger()||job.logRotator.numToKeep==-1)))  {
            cleanJobList += [["kind": VIOLATION_INCORRECT_LOG_ROTATION,"job": job.getFullName()]]
        }
    }
    if(job.nextBuildNumber == 1 ) {
        def file = job.getConfigFile().getFile();
        long modified_in_seconds = TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis() - file.lastModified())
        def modified_in_days = (int)TimeUnit.SECONDS.toDays(modified_in_seconds)

      if(modified_in_days > DAYS_TO_KEEP_JOB) {
      if ((jobDescription==null)||(!(jobDescription.contains("This job/folder does not meet corporate standards")))) {
        cleanJobList += [["kind": VIOLATION_NEVER_EXECUTED,"job": job.getFullName()]]
   }
        }// if job description updated
      }// end if modified is greater then days to keep

    def lastBuild = job.getLastBuild()
    if(lastBuild) {
        def last_build_in_seconds = TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis() - lastBuild.getTime().getTime())
        def lastbuild_in_days = TimeUnit.SECONDS.toDays(last_build_in_seconds)
      if(lastbuild_in_days > DAYS_TO_KEEP_JOB) {

             if ((jobDescription==null)||(!(jobDescription.contains("This job/folder does not meet corporate standards")))){
               cleanJobList += [["kind": VIOLATION_NO_RECENT_BUILDS, "job": job.getFullName()]]
             }
               }// last build greater days to keep
    } //if lastBuild
    if (job.builds.size()>NUM_TO_KEEP.toInteger()){
            cleanJobList += [["kind": VIOLATION_TOO_MANY_BUILDS,"job": job.getFullName()]]}
            }
    return cleanJobList
}//end processJob

def correctViolations(lcldelList) {
    lcldelList.each  {
      def job =Jenkins.instance.getItemByFullName(it.job)
      if (!(job == null)){
      def jobClass=job.getClass().toString()
      // We are execluding pipeline jobs because a majority of them are jenkinsFiles. If we can differentiate between pipeline jobs and jenkinsfiles we can update this logic
      if (it.kind=="NOT CORRECTED SINCE PREVIOUS AUDIT"){
       if (dryRun)
       {
        println "This job will be deleted because it hasn't changed since the last audit " +it.job
       }
       else{
        job.delete()
       }
      }
      if(it.kind=="NO LOG ROTATION"||it.kind=="INCORRECT LOG ROTATION")
      {
      //If the job has incorrect or no rotation strategy we will correct it here
      if(dryRun){
        println "Updating  log rotation for job "+it.job}
      else{
        if (jobClass.contains("multibranch")||jobClass.contains("OrganizationFolder"))
        {
          job.setOrphanedItemStrategy(new com.cloudbees.hudson.plugins.folder.computed.DefaultOrphanedItemStrategy(true,DAYS_TO_KEEP_BUILDS,-1))
          job.save()
          job.doReload()
        }
        else{
            job.setBuildDiscarder(new hudson.tasks.LogRotator(DAYS_TO_KEEP_BUILDS,NUM_TO_KEEP))
            job.save()}
            job.doReload()
           }
           }//end "log ROTATION"
                  else
          if (it.kind=="TOO MANY BUILDS"){
          if(dryRun){
            def recent = job.builds.limit(NUM_TO_KEEP)
            for (build in job.builds){
            if (!recent.contains(build)){
              println "Preparing to delete: " + build}}
              }// end of dryRun
          else{
          def recent = job.builds.limit(NUM_TO_KEEP)
            if(job.builds.size()<500){
              for (build in job.builds){
                if (!recent.contains(build)){
                if(!(build.keepLog)){
                  build.delete()
                  }// end if keep log is false
                  }// if recent
                }// end for loop
               job.save()
               job.doReload()
           }// end if size greater then 500
          else {
           println "Clean this job manually " +job.getFullName()
                  }
                  }
                  }// too many builds
           else
             if(it.kind=="NEVER EXECUTED"||it.kind=="NO RECENT BUILDS")
           		{
                def lastBuild = job.getLastBuild()
                  if (lastBuild){
                def last_build_in_seconds = TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis() - lastBuild.getTime().getTime())
                def lastbuild_in_days = TimeUnit.SECONDS.toDays(last_build_in_seconds)
                if(lastbuild_in_days >= 365) {
                  job.delete()
                }
                }
                else
                {
                job.setDescription(reasonForDisable)
                job.setDisabled(true)
                job.save()
                job.doReload()
                }
                }//end if no recent builds
        else
          if (it.kind=="EMPTY FOLDER"){
          def file = job.getConfigFile().getFile();
          long modified_in_seconds = TimeUnit.MILLISECONDS.toSeconds(System.currentTimeMillis() - file.lastModified())
          def modified_in_days = (int)TimeUnit.SECONDS.toDays(modified_in_seconds)
            if(modified_in_days>=90){
              job.delete()
            }//end modified greater then 90
            else{
            job.setDescription(reasonForDisable)
            job.save()
            job.doReload()
            }//modified less then 90
          }// end empty folder

      }//if job isn't null
    }//end each
  }// end of correctViolations


Jenkins.instance.getItems().each {
    if (it instanceof Folder) {
        cleanJobList += processFolder(it)
    } else if (it instanceof OrganizationFolder || it instanceof WorkflowMultiBranchProject) {
        cleanJobList += processSpecialFolder(it)
    }
  else {
        cleanJobList += processJob(it)
    }
}




def sortedcleanJobList=cleanJobList.sort()
for (violations=0;violations< sortedcleanJobList.size();violations++){
    if (!(sortedcleanJobList[violations].kind== null)){
    delList += [["kind": sortedcleanJobList[violations].kind, "job": sortedcleanJobList[violations].job]]
   }// if violations not null
  correctViolations(delList)
  delList.clear()
}//end for violations in
