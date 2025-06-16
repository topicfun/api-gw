#!/usr/bin/env bash
# Deploy the api-gw Helm chart to a Kubernetes cluster and verify the route.

set -euo pipefail

RELEASE=api-gw-test
NAMESPACE=api-gw-test

cleanup() {
  helm uninstall "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1 || true
  kubectl delete ns "$NAMESPACE" >/dev/null 2>&1 || true
}
trap cleanup EXIT

printf 'Creating namespace %s...\n' "$NAMESPACE"
kubectl create ns "$NAMESPACE" >/dev/null 2>&1 || true

printf 'Installing Helm chart...\n'
helm upgrade --install "$RELEASE" ./charts/api-gw \
  --namespace "$NAMESPACE" \
  --set image.repository=api-gw \
  --set image.tag=latest \
  --wait

printf 'Checking deployment status...\n'
kubectl rollout status deployment/"$RELEASE" -n "$NAMESPACE"

printf 'Issuing test request...\n'
status=$(kubectl run curl --rm -i --restart=Never -n "$NAMESPACE" \
  --image=curlimages/curl:8.5.0 -- \
  -s -o /dev/null -w '%{http_code}' http://"$RELEASE"/api/configAPI/ || true)

if [ "$status" = "502" ]; then
  echo "Helm chart test successful: received $status as expected."
else
  echo "Helm chart test FAILED: expected 502 but got $status" >&2
  exit 1
fi

