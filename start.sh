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

function start_kdc() {
    docker-compose \
      -f docker-compose.yml \
      up \
        -d kdc-server-example-com
     &> /dev/null
}

function main() {
    build_images
    mkdir -p ./share
    start_kdc || err "Failed to start KDC"
    docker-compose up -d presto-example-com
}

main
