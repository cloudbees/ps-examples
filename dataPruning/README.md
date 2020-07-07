# JenkinsSizingScripts
This repository contains two primary folders *groovy* and *jobConfiguration*

## groovy
Groovy script to gather data from jobs on the masters.

###  checkComplianceDetails:
Has as a boolean parameter "getJobs". When set to true this script will report the jobs that violate the parameters defined within the script. Those parameters are as follows:

  * DAYS_TO_KEEP_BUILDS = 180
  * NUM_TO_KEEP= 20
  * DAYS_TO_KEEP_JOB = 365

  There is a corresponding parameter in the script block section that should the one defined at the job level. This duplication is a result of using pipelines at the on the OC.

### correctViolations:
Will take action on the jobs that violate the compliance rules. There is a boolean parameter "dryRun", when set to true the script will show the actions that would be taken if the script was truly executed. Those actions can take include:
* Modify job configuration to meet log rotation limits
* Delete builds that exceed the limits
* Flag/Delete jobs that haven't been used in the defined timeframe.
* Flag/Delete empty folders.

## jobConfiguration
The files within this folder contain xml code exported from the CloudBees Jenkins Operation Center. The purpose of these files is to easily create new jobs if they are deleted. Ideally these jobs should be added to the automation process at . Until that work is completed these files might be useful.

### To create a new job OC admins can run:



### To update the jobs after creation:



### To export jobs if changes are made on the IU


