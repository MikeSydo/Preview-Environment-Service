#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="preview-cluster"
INGRESS_NS="ingress-nginx"
APP_NS="preview-test"
RELEASE_NAME="preview-test"

echo "=== Recreate local preview environment ==="

if k3d cluster list | grep -q "${CLUSTER_NAME}"; then
  echo "Deleting existing cluster: ${CLUSTER_NAME}"
  k3d cluster delete "${CLUSTER_NAME}"
fi

echo "Creating k3d cluster..."
k3d cluster create "${CLUSTER_NAME}" \
  --api-port 6550 \
  -p "8081:80@loadbalancer" \
  -p "8443:443@loadbalancer" \
  --agents 1

echo "Adding/updating ingress-nginx Helm repo..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
helm repo update

echo "Installing ingress-nginx..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace "${INGRESS_NS}" \
  --create-namespace

echo "Waiting for ingress-nginx controller..."
kubectl rollout status deployment/ingress-nginx-controller -n "${INGRESS_NS}" --timeout=180s

echo "Linting Helm chart..."
helm lint helm/preview-app

echo "Deploying preview app..."
helm upgrade --install "${RELEASE_NAME}" helm/preview-app \
  --namespace "${APP_NS}" \
  --create-namespace \
  --set ingress.host="localhost"

echo "Waiting for preview app rollout..."
kubectl rollout status deployment/${RELEASE_NAME}-preview-app -n "${APP_NS}" --timeout=180s || true

echo "Resources:"
kubectl get pods,svc,ingress -n "${APP_NS}"

echo "Smoke test:"
curl -H "Host: localhost" http://localhost:8081 || true

echo "Done."