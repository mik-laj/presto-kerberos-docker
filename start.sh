#!/usr/bin/env bash

set -euo pipefail

function err() {
  echo -e "\u001b[31m[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*\u001b[0m" >&2
  return 1
}

function fix_host_permission() {
    HOST_USER_ID="$(id -ur)"
    HOST_GROUP_ID="$(id -gr)"
    docker run -v "${1}:${1}" --rm centos:7 bash -c "
        find \"${1}\" -print0 -user root 2>/dev/null \
           | xargs --null chown ${HOST_USER_ID}.${HOST_GROUP_ID} --no-dereference
    " &> /dev/null
}


function build_images() { 
    # By default it is number of CPUs
    n_processes=$(python -c 'import multiprocessing as mp; print(mp.cpu_count())')
    echo "max of processes: ${n_processes}"
    # Build each service in parallel instead of sequentially
    services=$(docker-compose config --services)
    for service in ${services}; do
      while [[ $(jobs -r | wc -l) -gt ${n_processes} ]]; do
        :
      done
      echo "Building docker service '${service}' as image"
      docker-compose build "${service}" &> /dev/null &
    done
    wait
    echo "All images built"
}

function start_kdc() {
    docker-compose -f docker-compose.yml up -d kdc-server-example-com &> /dev/null
}


function create_admin() {
    USERNAME=$1
    PASSWORD=$2

    docker-compose exec \
      -T kdc-server-example-com\
        /opt/kerberos-utils/create_admin.sh "${USERNAME}" "${PASSWORD}" &> /dev/null

    echo "Added principal for the admin."
    echo ""
    echo "  To login, run:"
    echo "    kadmin -p ${USERNAME}/admin@EXAMPLE.COM -w ${PASSWORD}"
    echo ""
}

function create_client() {
    USERNAME=$1
    PASSWORD=$2
    KEYTAB_FILE=$3

    docker-compose exec \
      -T kdc-server-example-com\
        /opt/kerberos-utils/create_client.sh "${USERNAME}" "${PASSWORD}" "${KEYTAB_FILE}" &> /dev/null

    echo "Added principal for the client."
    echo ""
    echo "  To use, run:"
    echo "    kinit -k ${USERNAME}@EXAMPLE.COM"
    echo "    klist"
    echo ""

}


function create_service() {
    SERVICE_TYPE=$1
    SERVICE_NAME=$2
    KEYTAB_FILE=$3

    docker-compose exec \
      -T kdc-server-example-com \
        /opt/kerberos-utils/create_service.sh "${SERVICE_TYPE}" "${SERVICE_NAME}" "${KEYTAB_FILE}" &> /dev/null

    echo "Added principal for the \"${SERVICE_NAME}\" service." 
}

function setup_kerberos_principals() {
    start_kdc || err "Failed to start KDC"
    create_admin "alice" "alice" || err "Failed to add principal for the admin"
    create_client "bob" "bob" "/root/share/client.keytab" || err "Failed to add principal for the client"
    create_service "HTTP" "presto" "/root/share/presto.keytab"|| err "Failed to add principal for the \"presto\" service"
}

function main() {
    build_images
    mkdir -p ./share
    setup_kerberos_principals || err "Fail to setup Kerberos Principals" || exit 1
    docker-compose up -d presto-example-com
}

main
