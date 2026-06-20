#!/bin/bash

set -e

echo "=== Preview Environments Platform - Local Bootstrap ==="
echo "Checking prerequisites..."

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

TOOLS=("docker" "kubectl" "helm" "k3d")

for tool in "${TOOLS[@]}"; do
    if command_exists "$tool"; then
        echo "✅ $tool is installed."
    else
        echo "❌ $tool is not installed. Please install it to continue."
        exit 1
    fi
done

echo "All prerequisites met!"
echo ""
echo "To create the local cluster, run:"
echo "  k3d cluster create preview-cluster --api-port 6550 -p \"8081:80@loadbalancer\" -p \"8443:443@loadbalancer\" --agents 1"
echo ""
echo "To install ingress-nginx, run:"
echo "  helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace"
echo ""
echo "Bootstrap complete. (Cluster creation is manual for now to ensure safety)."
