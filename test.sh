#!/usr/bin/env bash

set -euo pipefail

docker-compose run --rm -e KRB5_TRACE=/dev/null machine-example-com bash -c "
ls -lah /root/share/
kinit -kt /root/share/kerberos.keytab bob@EXAMPLE.COM;
klist;
curl -X POST --insecure --negotiate -u : 'https://krb5-presto-example-com:7778/v1/statement' --data 'SELECT 1'
"