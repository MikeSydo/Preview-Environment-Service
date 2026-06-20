# Onboarding Guide

This guide helps a new contributor understand and reproduce the full Preview Environments Platform locally.

## Prerequisites

Install the following tools before starting:

| Tool | Version | Install |
|------|---------|--------|
| Docker | any recent | https://docs.docker.com/get-docker/ |
| kubectl | 1.27+ | https://kubernetes.io/docs/tasks/tools/ |
| helm | 3.x / 4.x | https://helm.sh/docs/intro/install/ |
| k3d | 5.x | https://k3d.io/#installation |

Verify with:
```bash
bash scripts/bootstrap-local.sh
```

## Step 1: Create the Local Cluster

```bash
k3d cluster create preview-cluster \
  --k3s-arg "--disable=traefik@server:0" \
  --api-port 6550 \
  -p "8081:80@loadbalancer" \
  -p "8443:443@loadbalancer" \
  --agents 1
```

## Step 2: Install ingress-nginx

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

## Step 3: Install Argo CD

```bash
bash scripts/install-argocd.sh
```

Get the admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 --decode
```

Access the UI:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit https://localhost:8080 (user: admin)
```

## Step 4: Apply GitOps Manifests

```bash
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application.yaml
```

## Step 5: Enable Pull Request Preview Environments

Create a GitHub personal access token (PAT) with `repo` scope and register it:

```bash
kubectl create secret generic github-token \
  --from-literal=token=<YOUR_PAT> \
  -n argocd
```

Then apply the ApplicationSet:
```bash
kubectl apply -f argocd/applicationset-preview.yaml
```

See [docs/preview-lifecycle.md](preview-lifecycle.md) for how to verify preview environments.

## Image Tagging Strategy

The GitHub Actions workflow (`.github/workflows/preview-build.yml`) builds and pushes an image for each PR:

- **Tag format:** `ghcr.io/mikesydo/preview-app:pr-<PR number>`
- **Triggered by:** `pull_request` events — `opened`, `synchronize`, `reopened`
- **Registry:** GitHub Container Registry (GHCR)
- **Auth:** Uses the automatic `GITHUB_TOKEN` — no secrets configuration needed

The ApplicationSet picks up this tag automatically via the `image.tag: pr-{{number}}` Helm parameter.

## Testing the End-to-End Flow

1. Open a pull request in this repository.
2. Wait for the `Preview Build` workflow to complete — the image will be pushed to GHCR.
3. Within ~30 seconds, Argo CD creates a new Application `preview-pr-<number>`.
4. Add the host to `/etc/hosts` (or use `--resolve` with curl):
   ```bash
   echo "127.0.0.1 pr-<number>.localhost" | sudo tee -a /etc/hosts
   ```
5. Access the preview at `http://pr-<number>.localhost:8081`.
6. Close the PR to trigger automatic cleanup.
