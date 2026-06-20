# Local Setup Plan & Verification

This document outlines the local setup plan and verification steps for the Preview Environments Platform.

## Architecture

We use a local Kubernetes cluster for MVP testing.
- **Cluster Tool:** k3d
- **Ingress Controller:** ingress-nginx (mapped to local ports 8081/8443 on the host)
- **Deployment:** Helm charts deployed to a test namespace.

## Prerequisites

1. Install Docker, kubectl, helm, and k3d.
2. Ensure no existing services are listening on ports 8081 or 8443 on your local machine.

## Bootstrapping the Cluster

If you need to bootstrap the cluster from scratch:
1. Create the k3d cluster (disabling default Traefik to allow ingress-nginx to bind):
   ```bash
   k3d cluster create preview-cluster --k3s-arg "--disable=traefik@server:0" --api-port 6550 -p "8081:80@loadbalancer" -p "8443:443@loadbalancer" --agents 1
   ```
2. Install the `ingress-nginx` controller:
   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
   ```

## Helm Chart Verification

To verify the Helm chart structure and routing:

1. **Lint the Helm Chart:**
   Verify that the Helm chart has correct syntax:
   ```bash
   helm lint helm/preview-app
   ```

2. **Deploy the Test Release:**
   Deploy the preview Helm chart with the ingress host set to `localhost`:
   ```bash
   helm upgrade --install preview-test helm/preview-app --namespace preview-test --create-namespace --set ingress.host="localhost"
   ```

3. **Verify Reachability:**
   Check if the ingress-nginx controller successfully routes requests to the deployed app pod:
   ```bash
   curl -i http://localhost:8081
   ```
   You should receive a `200 OK` response from the demo application container containing the pod name and server address details.
