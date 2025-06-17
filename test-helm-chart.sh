#!/usr/bin/env bash
# Deploy the api-gw Helm chart to a Kubernetes cluster and verify the route.

set -euo pipefail

# Set Docker environment to Minikube's Docker daemon
# shellcheck disable=SC2046
eval $(minikube -p minikube docker-env --shell bash)

# Fail fast if kubectl cannot reach a cluster so that Helm does not hang
if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "ERROR: Kubernetes cluster unreachable. Ensure kubectl is configured." >&2
  exit 1
fi

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
if ! helm upgrade --install "$RELEASE" ./charts/api-gw \
  --namespace "$NAMESPACE" \
  --set image.repository=api-gw \
  --set image.tag=latest \
  --wait --debug 2>helm-install.log; then
  echo "Helm upgrade failed. Log output:" >&2
  cat helm-install.log >&2
  printf '\nPods status after failed upgrade:\n' >&2
  kubectl get pods -n "$NAMESPACE" >&2 || true
  printf '\nEvents for pods:\n' >&2
  kubectl describe pods -n "$NAMESPACE" >&2 || true
  exit 1
fi

printf 'Pods status after install:\n'
kubectl get pods -n "$NAMESPACE" || true

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

