#!/usr/bin/env bash


source ./set-env.sh
#get an letsencrypt cert
#https://blog.codeship.com/how-to-deploy-wildcard-ssl-certificates-using-lets-encrypt/
sudo certbot --server https://acme-v02.api.letsencrypt.org/directory --manual --preferred-challenges dns -m andreas.caternberg@gmail.com    --agree-tos   -d *.$DOMAIN certonly

#see https://support.cloudbees.com/hc/en-us/articles/360018094412-Deploy-Self-Signed-Certificates-in-Masters-and-Agents-Custom-Location-
