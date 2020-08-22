#!/usr/bin/env bash

set -euo pipefail

docker-compose run --rm -e KRB5_TRACE=/dev/null machine-example-com bash -c "
ls -lah /root/share
k
kinit -kt /root/share/client.keytab bob@EXAMPLE.COM
klist -ktK
klist
curl -q -v -X POST --insecure --negotiate -u : 'https://presto-kerberos:7778/v1/statement' --data 'SELECT 1'
"