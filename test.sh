#!/usr/bin/env bash

set -euo pipefail

function post() {
	docker-compose run --rm -e KRB5_TRACE=/dev/null machine-example-com bash -c "
	ls -lah /root/share/
	kinit -kt /root/share/kerberos.keytab bob@EXAMPLE.COM;
	klist;
	curl -X POST --insecure --negotiate -u : $1 --data '$2'
	"
}

# function get() {
# 	docker-compose run --rm -e KRB5_TRACE=/dev/null machine-example-com bash -c "
# 	kinit -kt /root/share/kerberos.keytab bob@EXAMPLE.COM > /dev/null;
# 	klist> /dev/null;
# 	curl -v -X GET --insecure --negotiate -u : $1
# 	"
# }
docker-compose run --rm -e KRB5_TRACE=/dev/null machine-example-com bash -c "
ls -lah /root/share/
kinit -kt /root/share/kerberos.keytab bob@EXAMPLE.COM;
klist;
curl -X POST --insecure --negotiate -u : 'https://krb5-presto-example-com:7778/v1/statement' --data 'SELECT 1'
"