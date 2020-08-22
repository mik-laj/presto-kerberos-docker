#!/usr/bin/env bash

set -euo pipefail

SERVICE_NAME=$1
SERVICE_TYPE=$2
KEYTAB_FILE=$3

DOMAIN_NAME=example.com
REALM_NAME=EXAMPLE.COM

cat << EOF | kadmin.local &>/dev/null
add_principal -randkey "${SERVICE_NAME}.${DOMAIN_NAME}@${REALM_NAME}"
add_principal -randkey "${SERVICE_TYPE}/${SERVICE_NAME}.${DOMAIN_NAME}@${REALM_NAME}"
ktadd -k ${KEYTAB_FILE} -norandkey "${SERVICE_NAME}.${DOMAIN_NAME}@${REALM_NAME}"
ktadd -k ${KEYTAB_FILE} -norandkey "${SERVICE_TYPE}/${SERVICE_NAME}.${DOMAIN_NAME}@${REALM_NAME}"
quit
EOF

chmod 777 "${KEYTAB_FILE}" &>/dev/null

echo "Created service: ${SERVICE_NAME}"