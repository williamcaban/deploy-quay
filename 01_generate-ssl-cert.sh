#!/bin/bash

openssl x509 -req -in ssl.csr -CA rootCA.pem \
-CAkey rootCA.key -CAcreateserial -out ssl.cert \
-days 356 -extensions v3_req -extfile openssl.cnf