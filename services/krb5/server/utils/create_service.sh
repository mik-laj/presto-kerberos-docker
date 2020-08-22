#!/usr/bin/env bash

set -xeuo pipefail

SERVICE_TYPE=$1
SERVICE_NAME=$2
KEYTAB_FILE=$3

cat << EOF | kadmin.local
add_principal -randkey "krb5-${SERVICE_NAME}-example-com.example.com@EXAMPLE.COM"
add_principal -randkey "${SERVICE_TYPE}/krb5-${SERVICE_NAME}-example-com.example.com@EXAMPLE.COM"
ktadd -k ${KEYTAB_FILE} -norandkey "krb5-${SERVICE_NAME}-example-com.example.com@EXAMPLE.COM"
ktadd -k ${KEYTAB_FILE} -norandkey "${SERVICE_TYPE}/krb5-${SERVICE_NAME}-example-com.example.com@EXAMPLE.COM"
listprincs
quit
EOF
chmod 777 "${KEYTAB_FILE}"
