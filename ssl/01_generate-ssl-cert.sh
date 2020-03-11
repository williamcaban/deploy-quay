#!/bin/bash

echo "Creating root CA"
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -config openssl.cnf -nodes -key rootCA.key -days 1024 -out rootCA.pem

echo "Create CSR and private key"
openssl req -nodes -new -config openssl.cnf -keyout ssl.key -out ssl.csr

echo "Signing the certificate"
openssl x509 -req -in ssl.csr -CA rootCA.pem \
-CAkey rootCA.key -CAcreateserial -out ssl.cert -days 500 -sha256

# OTHER OPTION for self-signed certificate without root certs
#echo "Generate self-signed cert and priate key"
#openssl req  -nodes -new -x509  -keyout ssl.key -out ssl.cert -config openssl.cnf 
