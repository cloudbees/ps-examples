#!/usr/bin/env bash



source ./set-env.sh

#see https://cloudbees.atlassian.net/wiki/spaces/PS/pages/595493043/Setting+TLS+at+Ingress


createselfSignedCert ()
{
        #exportXIPIO
        echo "create dirr: $CERT_DIR"
        echo "DOMAIN: $DOMAIN"
        mkdir $CERT_DIR
        ##create self signed cert
        ###Remove comment below to create a certificate.crt
        echo "openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout $CERT_DIR/privateKey.key -out $CERT_DIR/certificate.crt \
         -subj /C=DE/ST=Berlin/L=Berlin/O=Cloudbees/OU=PS/CN=$DOMAIN"
        echo -n "Create cert now :Y/N "
        read YN
        echo $YN
        if [  "$YN" == "Y" ]
        then
            rm $CERT_DIR/*
            openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout $CERT_DIR/privateKey.key -out $CERT_DIR/certificate.crt \
             -subj "/C=DE/ST=Berlin/L=Berlin/O=Cloudbees/OU=PS/CN=$DOMAIN"
            #Country Name (2 letter code) []:DE
            #State or Province Name (full name) []:Berlin
            #Locality Name (eg, city) []:Berlin
            #Organization Name (eg, company) []:cloudbees
            #Organizational Unit Name (eg, section) []:ps
            #Common Name (eg, fully qualified host name) []:cje.35.163.55.174.xip.io
            #Email Address []:acaternberg@cloudbees.com

            #display  the cert
            openssl x509 -in $CERT_DIR/certificate.crt -text

            return  0
       else
            echo "$0 $@ Aborted"
           return 1
       fi
}





createselfSignedCert




