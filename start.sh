#!/usr/bin/env bash

set -euo pipefail

function err() {
  echo -e "\u001b[31m[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*\u001b[0m" >&2
  return 1
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
        err "Fail to create network"
        return ${RET_CODE}
    fi
    echo "Created network: ${network_name}"
}


function main() {
    build_images
    create_network || exit 1
    mkdir -p ./share
    docker-compose up -d
}

main