#!/usr/bin/env bash

set -euo pipefail

# By default it is number of CPUs
n_processes=$(python -c 'import multiprocessing as mp; print(mp.cpu_count())')
echo "max of processes: ${n_processes}"
docker-compose config --services |\
  xargs -P "${n_processes}" -t -n 1 \
    docker-compose build
