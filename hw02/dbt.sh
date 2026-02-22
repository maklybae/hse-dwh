#!/usr/bin/env bash
# Wrapper to run dbt commands inside the Spark/Iceberg container.
# Usage:  ./dbt.sh run
#         ./dbt.sh compile
#         ./dbt.sh test
#         ./dbt.sh debug
#         ./dbt.sh deps        (force reinstall packages)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Default dbt args if none provided
DBT_ARGS=("${@:-"--help"}")

exec docker compose \
  -f "$SCRIPT_DIR/docker-compose-dwh.yaml" \
  run --rm \
  dwh-dbt \
  "${DBT_ARGS[@]}" --profiles-dir .
