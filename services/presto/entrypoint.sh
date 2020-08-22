#!/bin/bash

set -euo pipefail

function check_service {
    INTEGRATION_NAME=$1
    CALL=$2
    MAX_CHECK=${3}

    echo -n "${INTEGRATION_NAME}: "
    while true
    do
        set +e
        LAST_CHECK_RESULT=$(eval "${CALL}" 2>&1)
        RES=$?
        set -e
        if [[ ${RES} == 0 ]]; then
            echo -e " \e[32mOK.\e[0m"
            break
        else
            echo -n "."
            MAX_CHECK=$((MAX_CHECK-1))
        fi
        if [[ ${MAX_CHECK} == 0 ]]; then
            echo -e " \e[31mERROR!\e[30m"
            echo "Maximum number of retries while checking service. Exiting"
            break
        else
            sleep 1
        fi
    done
    if [[ ${RES} != 0 ]]; then
        echo "Service could not be started!"
        echo
        echo "${LAST_CHECK_RESULT}"
        echo
        return ${RES}
    fi
}

function log() {
  echo -e "\u001b[32m[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*\u001b[0m" >&2
}

if [ -f /tmp/presto-initiaalized ]; then
  exec /bin/sh -c "$@"
fi

log "Generate self-signed SSL certificate"
JKS_KEYSTORE_FILE=/tmp/ssl_keystore.jks
JKS_KEYSTORE_PASS=presto
keytool \
    -genkeypair \
    -alias "presto-ssl" \
    -keyalg RSA \
    -keystore "${JKS_KEYSTORE_FILE}" \
    -validity 10000 \
    -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown"\
    -storepass "${JKS_KEYSTORE_PASS}"

JVM_CONFIG="/usr/lib/presto/etc/jvm.config"
log "Add debug Kerberos options to ${JVM_CONFIG}"
echo "-Dsun.security.krb5.debug=true" >> "${JVM_CONFIG}"
echo "-Dlog.enable-console=true" >> "${JVM_CONFIG}"

cat "${JVM_CONFIG}"
PRESTO_CONFIG="/usr/lib/presto/etc/config.properties"
log "Set up SSL and Kerberos in ${PRESTO_CONFIG}"
echo "http-server.authentication.type=KERBEROS" >> "${PRESTO_CONFIG}"
echo "http-server.authentication.krb5.service-name=HTTP" >> "${PRESTO_CONFIG}"
echo "http-server.authentication.krb5.principal-hostname=presto-kerberos.example.com" >> "${PRESTO_CONFIG}"
echo "http-server.authentication.krb5.keytab=${KRB5_KTNAME}" >> "${PRESTO_CONFIG}"
echo "http.authentication.krb5.config=${KRB5_CONFIG}" >> "${PRESTO_CONFIG}"
echo "http-server.https.enabled=true" >> "${PRESTO_CONFIG}"
echo "http-server.https.port=7778" >> "${PRESTO_CONFIG}"
echo "http-server.https.keystore.path=${JKS_KEYSTORE_FILE}" >> "${PRESTO_CONFIG}"
echo "http-server.https.keystore.key=${JKS_KEYSTORE_PASS}"  >> "${PRESTO_CONFIG}"
echo "node.internal-address-source=FQDN" >> "${PRESTO_CONFIG}"

cat "${PRESTO_CONFIG}"
log "Waiting for keytab ${KRB5_KTNAME}"
check_service "Keytab" "test -f ${KRB5_KTNAME}" 30
touch /tmp/presto-initiaalized
exec "$@"