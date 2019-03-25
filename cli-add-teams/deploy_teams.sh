#!/usr/bin/env bash


# Setting a return status for a function
team_json_builder() {
  team_name=$1
  team=$(cat <<EOF
  {
      "data": {
          "displayName": "$team_name",
          "icon": {
              "color": "#dd6669",
              "name": "truck"
          },
          "members": [
              {
                  "id": "lcorbo",
                  "roles": [
                      "TEAM_ADMIN"
                  ]
              }
          ],
          "name": "$team_name",
          "provisioningRecipe": "basic"
      },
      "version": "1"
  }
EOF)
echo $team > "teams/$team_name.json"
return
}

java -jar jenkins-cli.jar -s http://jenkins.$JENKINS_IP.xip.io/cjoc/ -p 50000 -noKeyAuth -auth $JENKINS_USERNAME:$JENKINS_TOKEN team-creation-recipes --put < recipe/smallerdisk.json
echo ""

if [ ! -d teams ]; then
  mkdir -p teams;
fi

#        000{1..9} 00{10..99} 0{100..999} {1000..3500}
for i in 000{1..9} 00{10..99} 0{100..500} ; do
    team_name="team$i"
    team_json=$(team_json_builder $team_name)
    java -jar jenkins-cli.jar -s http://jenkins.$JENKINS_IP.xip.io/cjoc/ -p 50000 -noKeyAuth -auth $JENKINS_USERNAME:$JENKINS_TOKEN teams $team_name --put < teams/$team_name.json
    echo ""
done
