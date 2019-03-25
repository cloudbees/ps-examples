

# cli-add-team-teams

The example shows how to use a bash script to add team masters to Jenkins kubernetes cluster's cjoc.  This example script assumes you used the cluster-build script to prepare a kubernetes cluster.

To use this script you'll need a configured CJOC that can create team masters, and you'll the *jenkins-cli.jar*, more information is available at [Jenkins CLI](https://go.cloudbees.com/docs/cloudbees-documentation/admin-cje/reference/cli/).

Once the cjoc is ready, set the following environmental variables in the session that will run the script.

* *JENKINS_IP*       =  The IP address of the cjoc.
* *JENKINS_USERNAME* =  The username of the admin account owns the token you created for running the cli commands.
* *JENKINS_TOKEN*    =  The user token created with the admin account *JENKINS_USERNAME*.

Once these variables are defined, execute the script deploy_teams.sh and you should see output similar to:

```
{"version":"1","data":{"id":null,"message":"Recipes list updated successfully","status":"success"}}
{"version":"1","data":{"id":"team0001","message":"Team [team0001] updated successfully","status":"success"}}
{"version":"1","data":{"id":"team0002","message":"Team [team0002] updated successfully","status":"success"}}
{"version":"1","data":{"id":"team0003","message":"Team [team0003] updated successfully","status":"success"}}
{"version":"1","data":{"id":"team0004","message":"Team [team0004] updated successfully","status":"success"}}
{"version":"1","data":{"id":"team0005","message":"Team [team0005] updated successfully","status":"success"}}
{"version":"1","data":{"id":"team0006","message":"Team [team0006] updated successfully","status":"success"}}
...
...
{"version":"1","data":{"id":"team0006","message":"Team [team0500] updated successfully","status":"success"}}
```
When the script completes 500 teams have been created on the kubernetes cluster.
