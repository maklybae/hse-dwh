#!/usr/bin/env bash
set -euo pipefail

# Auto-run dbt deps if packages are not installed yet
if [ ! -d "dbt_packages" ] || [ ! -f "package-lock.yml" ]; then
  echo "==> Running dbt deps (packages not found)..."
  dbt deps
fi

exec dbt "$@"
