#!/usr/bin/env bash
# Creates all shared Docker networks.
# Run once before starting any compose stack.
# Safe to re-run: existing networks are left intact.

set -euo pipefail

create_network() {
  local name="$1"
  if docker network inspect "$name" &>/dev/null; then
    echo "Network '$name' already exists, skipping"
  else
    docker network create "$name"
    echo "Network '$name' created"
  fi
}

# postgres-ha-net — etcd, Patroni nodes, HAProxy, migrations
create_network postgres-ha-net

# kafka-net — Kafka broker, Connectors
create_network kafka-net

# dwh-net — MinIO, Iceberg REST, Spark cluster, dbt
create_network dwh-net

echo "All networks are ready"
