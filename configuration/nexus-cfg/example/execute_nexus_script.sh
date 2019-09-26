#!/usr/bin/env bash

curl -X POST -u admin:admin123 --header "Content-Type: text/plain" 'http://127.0.0.1:8081/service/rest/v1/script/jenkins/run'
