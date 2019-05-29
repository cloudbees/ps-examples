

# Experimentation Process

1. Build cluster
  1. Run script cluster-build/gcloud_deployment.sh

2. Configure CJOC
  1. Add license
  2. Create admin user account
    * Example username: corbolj
    * Example password: welcome
  3. Create token for username.

3. Prep Test Environment
  1. The following environment variables
    * *JENKINS_IP*
    * *JENKINS_USERNAME*
    * *JENKINS_TOKEN*

4. Download jenkins-cli.jar in same location as the script deploy_teams.sh

5. Run the script deploy_teams.sh

6. Edit deploy_teams.sh script to increase number of masters added.


# Issues and Resolutions During the Experimentation Process

1. Issue: Unable to build cluster, or team masters initialized but become unschedulable.
    Cause: default quotes are too low for testing.
    Resolution:  Quotas raised to:
      * CPUs: 2400
      * Persistent Disk SSD (GB) 81.92 (TB)

2. Issue: Regions intermittently unable to host clusters and pods randomly became unschedulable.
    Cause: Despite quote raise, disks limits are still being hit due to disks not being deleted with clusters.
    Resolution: Manually delete disks after cluster is removed.

3. Issue: CJOC became unresponsive after about 850 team masters were added.
    Cause: 504 Gateway Timeout error was occurring on Ingress for CJOC.
    Resolution:  Increase timeouts using the following annotations:
    ```
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
    ```

4. Issue: Disk quotas still being hit now that more masters are able to be added.
    Cause: Either master allocates 50 gb of disk space.  50 X 3500 = 175000 or 175 TB, with is much lagers than the already big 81.92 limit in place.  
    Resolution:  Lower disk size to 20 GB so 20 X 3500 = 70000 or 70 TB, which is withen our quotas.
    * This was done by changing the basic recipe to the template listed in cli-add-teams/recipe/smallerdisk.json before adding the masters.
    * This step is done on line 33 of the deploy_teams.sh script.

5. Issue: Team masters become harder and hard to join once you pass 800 team masters.  Failures, timeouts, make process hard to automate. Manually it takes more and more time to get the newly added masters to successfully connect.
    Cause: Some unknown bottleneck, likely either java threading related or the result of the current network configuration.
    Resolution: Unknown at this time.
