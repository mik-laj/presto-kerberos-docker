#!/usr/bin/env bash

set -euo pipefail

docker-compose run -e KRB5_TRACE=/dev/stderr machine-example-com kadmin -p alice/admin@EXAMPLE.COM -w alice