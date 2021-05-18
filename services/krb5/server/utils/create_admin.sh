#!/usr/bin/env bash

set -euo pipefail

USERNAME=$1
PASSWORD=$2

REALM_NAME=EXAMPLE.COM

cat << EOF | kadmin.local &>/dev/null
add_principal -pw $PASSWORD "${USERNAME}/admmin@${REALM_NAME}"
listprincs
quit
EOF

echo "Created admin: ${USERNAME}"
