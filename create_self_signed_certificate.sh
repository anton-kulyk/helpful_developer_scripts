#!/bin/bash

BASE_DIR='~/http_certs/'
NAME=$1 # Use your own domain name
DOMAIN_DIR=$BASE_DIR$1
PASS='123456'


if [ -d $DOMAIN_DIR ]
then
    rm -rf $DOMAIN_DIR
fi

mkdir $DOMAIN_DIR

function print_message(){
  echo $1
}

######################
# Become a Certificate Authority
######################

print_message "Generate private key $LINENO"
openssl genrsa -out $1/myCA.key 2048

print_message "Generate root certificate $LINENO"
openssl req -x509 -new -nodes -key $DOMAIN_DIR/myCA.key -sha256 -days 825 -out $DOMAIN_DIR/myCA.pem -subj "/C=UA/ST=Kiev/L=Kiev/O=Global Security/OU=IT Department/CN=$1"

######################
# Create CA-signed certs
######################

print_message "Generate a private key $LINENO"
openssl genrsa -out $DOMAIN_DIR/$NAME.key 2048

print_message "Create a certificate-signing request $LINENO"
openssl req -new -key $DOMAIN_DIR/$NAME.key -out $DOMAIN_DIR/$NAME.csr -subj "/C=UA/ST=Kiev/L=Kiev/O=Global Security/OU=IT Department/CN=$1"

print_message "Create a config file for the extensions $LINENO"
>$DOMAIN_DIR/$NAME.ext cat <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $NAME # Be sure to include the domain name here because Common Name is not so commonly honoured by itself
DNS.2 = bar.$NAME # Optionally, add additional domains (I've added a subdomain here)
IP.1 = 192.168.0.13 # Optionally, add an IP address (if the connection which you have planned requires it)
EOF

print_message "Create the signed certificate $LINENO"
openssl x509 -req -in $DOMAIN_DIR/$NAME.csr -CA $DOMAIN_DIR/myCA.pem -CAkey $DOMAIN_DIR/myCA.key -CAcreateserial \
-out $DOMAIN_DIR/$NAME.crt -days 825 -sha256 -extfile $DOMAIN_DIR/$NAME.ext
