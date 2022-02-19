#!/usr/bin/bash

# Based on script from https://jason.whitehorn.us/blog/2019/02/01/client-certificate-auth-with-nginx/

#Username comes as argument from a script

USERNAME=$1

if [ -z "$USERNAME" ]; then
   echo "Username not supplied"
   exit
fi

PROJECT_NAME="clubhouse"
CA_ROOT="$(pwd)/${PROJECT_NAME}_certs"
CERT_DUR=365 #1 year
KEY_LEN=2048
OPENSSL_CONF="$(pwd)/${PROJECT_NAME}_openssl.cnf"

#Setting OPENSSL_CONF env variable allow for openssl to use custom config file
export OPENSSL_CONF=$OPENSSL_CONF

openssl genrsa -aes256 -out $CA_ROOT/certs/users/$USERNAME.key $KEY_LEN

openssl req -new -key $CA_ROOT/certs/users/$USERNAME.key -sha256 \
	    -out $CA_ROOT/certs/users/$USERNAME.csr

openssl x509 -req -days $CERT_DUR \
	    -in $CA_ROOT/certs/users/$USERNAME.csr \
	    -CA $CA_ROOT/certs/ca.crt \
      	    -CAkey $CA_ROOT/private/ca.key \
	    -CAserial $CA_ROOT/serial \
	    -CAcreateserial \
	    -out $CA_ROOT/certs/users/$USERNAME.crt

openssl pkcs12 -export -clcerts \
	-in $CA_ROOT/certs/users/$USERNAME.crt \
	-inkey $CA_ROOT/certs/users/$USERNAME.key \
	-out $CA_ROOT/certs/users/$USERNAME.p12
