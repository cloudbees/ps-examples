#!/usr/bin/env bash

curl -X POST -u admin:admin123 --header 'Content-Type: application/json' \
    http://127.0.0.1:8081/service/rest/v1/script \
    -d '{"name":"jenkins","type":"groovy","content":"repository.createMavenProxy('\''jenkins'\'','\''https://repo.cloudbees.com/content/repositories/dev-connect/'\'')"}'
    