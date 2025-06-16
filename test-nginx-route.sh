#!/usr/bin/env bash
# Simple script to verify the nginx route without any Java services.
set -euo pipefail

# Ensure we clean up the nginx container on exit
cleanup() {
  docker compose down >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Start only the nginx service
printf 'Starting nginx...\n'
docker compose up -d nginx

# Determine the container name assigned by docker compose
container=$(docker compose ps -q nginx)
echo "container: $container"

# Figure out the compose network the container is attached to
# We need the network name, so iterate over the map keys.
network=$(docker inspect -f '{{range $name, $_ := .NetworkSettings.Networks}}{{println $name}}{{end}}' "$container" | head -n 1)
echo "network: $network"

# Give nginx a moment to start
sleep 5

# Issue a request from a temporary curl container on the same network.
# No backends are running, so nginx should return 502 Bad Gateway. api/configAPI
status=$(docker run --rm --network "$network" curlimages/curl:8.5.0 -s -o /dev/null -w '%{http_code}' http://nginx/api/configAPI/ || true)

if [ "$status" = "502" ]; then
  echo "Route test successful: received $status as expected."
else
  echo "Route test FAILED: expected 502 but got $status" >&2
  exit 1
fi