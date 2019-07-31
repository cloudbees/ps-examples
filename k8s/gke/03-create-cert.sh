#!/usr/bin/env bash



source ./set-env.sh

#see https://cloudbees.atlassian.net/wiki/spaces/PS/pages/595493043/Setting+TLS+at+Ingress

#Certificate Signing Request (CSR)
#see https://support.globalsign.com/customer/portal/articles/1221018-generate-csr---openssl
openssl req -out CSR.csr -new -newkey rsa:2048 -nodes -days 365 -keyout privatekey.key -subj "/C=DE/ST=Berlin/L=Berlin/O=Cloudbees/OU=PS/CN=caternberg.eu"
#Use the resulting CSR.csr as a input for:
open  https://zerossl.com/free-ssl/
#reult is a valid signed cert as well as the root CA  within one file: domain-crt.txt




