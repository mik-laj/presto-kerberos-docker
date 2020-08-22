#!/usr/bin/env bash

set -euo pipefail

USERNAME=$1
PASSWORD=$2

cat << EOF | kadmin.local &>/dev/null
add_principal -pw $PASSWORD "${USERNAME}/admmin@EXAMPLE.COM"
listprincs
quit
EOF

echo "Created admin: ${USERNAME}"