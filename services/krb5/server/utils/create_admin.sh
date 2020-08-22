#!/usr/bin/env bash

set -xeuo pipefail

USERNAME=$1
PASSWORD=$2

cat << EOF | kadmin.local
add_principal -pw $PASSWORD "${USERNAME}/admmin@EXAMPLE.COM"
listprincs
quit
EOF