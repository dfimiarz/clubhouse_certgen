#!/usr/bin/bash

# Script based on https://jason.whitehorn.us/blog/2019/02/01/client-certificate-auth-with-nginx/

PROJECT_NAME="clubhouse"
CA_ROOT="$(pwd)/${PROJECT_NAME}_certs"
CA_CERT_DUR=1095 #3 years
CA_KEY_LEN=4096
OPENSSL_CONF_TEMPLATE="$(pwd)/openssl.cnf.template"
OPENSSL_CONF="$(pwd)/${PROJECT_NAME}_openssl.cnf"

#Setting OPENSSL_CONF env variable allow for openssl to use custom config file
export OPENSSL_CONF=$OPENSSL_CONF

#Create custom config file base on a template
cp $OPENSSL_CONF_TEMPLATE $OPENSSL_CONF

#Replace {{ca_dif}} template var with the actual path to openssl config file
sed "s@{{ca_dir}}@${CA_ROOT}@g" $OPENSSL_CONF_TEMPLATE > $OPENSSL_CONF

mkdir -p $CA_ROOT
cd $CA_ROOT

mkdir -p ./certs/users
mkdir ./crl
mkdir ./private

touch $CA_ROOT/index.txt
echo "01" > $CA_ROOT/crlnumber

openssl genrsa -aes256 -out $CA_ROOT/private/ca.key $CA_KEY_LEN

openssl req -new -x509 -days $CA_CERT_DUR -sha256 \
    -key $CA_ROOT/private/ca.key \
    -out $CA_ROOT/certs/ca.crt

openssl ca -name CA_default -gencrl \
    -crldays $CA_CERT_DUR \
    -keyfile $CA_ROOT/private/ca.key \
    -cert $CA_ROOT/certs/ca.crt \
    -out $CA_ROOT/private/ca.crl
