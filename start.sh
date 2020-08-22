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

function create_network() {
    network_name="example.com"
    network="10.5.0.0/24"
    gateway="$(echo ${network} | cut -f1-3 -d'.').254"

    docker network ls | awk '{print $2}' | grep "^${network_name}$" &> /dev/null
    if [[ $? -eq 0 ]]; then
      echo "Docker network '${network_name}' already exists. Skipping."
      return 0
    fi

    docker network create \
        --driver=bridge \
        --subnet="${network}" \
        --ip-range="${network}" \
        --gateway="${gateway}" \
        "${network_name}" &> /dev/null

    RET_CODE=$?
    if [[ ${RET_CODE} != 0 ]]; then
        err "Faill to create network"
        return ${RET_CODE}
    fi
    echo "Created network: ${network_name}"
}

function start_kdc() {
    docker-compose \
      -f docker-compose.yml \
      up \
        -d kdc-server-example-com
#     &> /dev/null
}


function create_admin() {
    USERNAME=alice
    PASSWORD=alice
    docker-compose exec \
      -T kdc-server-example-com\
        /opt/kerberos-utils/create_admin.sh "${USERNAME}" "${PASSWORD}"
#         \
#        &> /dev/null
    echo "Added principal for the admin."
    echo ""
    echo "  To login, run:"
    echo "    kadmin -p ${USERNAME}/admin@EXAMPLE.COM -w ${PASSWORD}"
    echo ""
}

function create_client() {
    USERNAME=bob
    PASSWORD=bob
    KEYTAB_FILE=/root/share/bob.keytab

    docker-compose exec \
      -T kdc-server-example-com\
        /opt/kerberos-utils/create_client.sh "${USERNAME}" "${PASSWORD}" "${KEYTAB_FILE}"
#         \
#        &> /dev/null

    mkdir -p ./share/machine/
    fix_host_permission "$PWD/share/kdc/"
    mv ./share/kdc/bob.keytab ./share/machine/kerberos.keytab    
    echo "Added principal for the client."
    echo ""
    echo "  To use, run:"
    echo "    kinit -kt ${KEYTAB_FILE} ${USERNAME}@EXAMPLE.COM"
    echo "    klist"
    echo ""

}


function create_service() {
    SERVICE_TYPE=$1
    SERVICE_NAME=$2
    KEYTAB_FILE=/root/share/krb5-service.keytab

    docker-compose exec \
      -T kdc-server-example-com \
        /opt/kerberos-utils/create_service.sh "${SERVICE_TYPE}" "${SERVICE_NAME}" "${KEYTAB_FILE}"
#         \
#        &> /dev/null

    mkdir -p ./share/${SERVICE_NAME}/
    fix_host_permission "$PWD/share/kdc/"
    mv ./share/kdc/krb5-service.keytab ./share/${SERVICE_NAME}/kerberos.keytab   
    echo "Added principal for the \"${SERVICE_NAME}\" service." 
}

function setup_kerberos_principals() {
    start_kdc || err "Failed to start KDC"
    create_admin || err "Failed to add principal for the admin"
    create_client || err "Failed to add principal for the client"
    create_service "HTTP" "presto" || err "Failed to add principal for the \"presto\" service"
}

function main() {
    build_images
    create_network || exit 1
    mkdir -p ./share
    setup_kerberos_principals || err "Fail to setup Kerberos Principals" || exit 1
    docker-compose up presto-example-com
}

main