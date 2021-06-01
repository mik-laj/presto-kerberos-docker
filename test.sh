#!/usr/bin/env bash

set -euo pipefail

SQL=${1:-SELECT 1}
./send-presto-query.sh "$SQL"
