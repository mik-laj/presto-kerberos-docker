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

function main() {
    build_images
    mkdir -p ./share
    docker-compose up -d
}

main
