#!/usr/bin/env bash

set -euo pipefail

USERNAME=$1
PASSWORD=$2
KEYTAB_FILE=$3

cat << EOF | kadmin.local &>/dev/null
add_principal -pw $PASSWORD "${USERNAME}@EXAMPLE.COM"
ktadd -k ${KEYTAB_FILE} -norandkey "${USERNAME}@EXAMPLE.COM"
listprincs
quit
EOF

chmod 777 "${KEYTAB_FILE}" &>/dev/null

echo "Created client: ${USERNAME}"