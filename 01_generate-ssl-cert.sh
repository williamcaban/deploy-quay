#!/bin/bash

echo "Creating root CA"
openssl genrsa -out rootCA.key 2048

openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem

#openssl req -x509 -new -config openssl.cnf -nodes -key rootCA.key -days 1024 -out rootCA.pem


echo "Create certificate and private key"
#openssl genrsa -out ssl.key 2048
#openssl req -new -key ssl.key -out ssl.csr

openssl req -new -config openssl.cnf -keyout ssl.key -out ssl.csr


echo "Signing the certificate"
openssl x509 -req -in ssl.csr -CA rootCA.pem \
-CAkey rootCA.key -CAcreateserial -out ssl.cert -days 500 -sha256


# # echo "Creating certificate and private key"
# openssl x509 -req -in ssl.csr -CA rootCA.pem \
# -CAkey rootCA.key -CAcreateserial -out ssl.cert \
# -days 356 -extensions v3_req -extfile openssl.cnf

