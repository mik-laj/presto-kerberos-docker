#!/usr/bin/env bash

set -euo pipefail

USERNAME=$1
PASSWORD=$2
KEYTAB_FILE=$3

REALM_NAME=EXAMPLE.COM

cat << EOF | kadmin.local &>/dev/null
add_principal -pw $PASSWORD "${USERNAME}@${REALM_NAME}"
ktadd -k ${KEYTAB_FILE} -norandkey "${USERNAME}@${REALM_NAME}"
listprincs
quit
EOF

chmod 777 "${KEYTAB_FILE}" &>/dev/null

echo "Created client: ${USERNAME}"