# Preview Environment Lifecycle

This document describes how pull request-based preview environments are created and cleaned up using Argo CD ApplicationSet.

## Overview

When a pull request is opened:
1. GitHub Actions builds the container image and pushes it to GHCR as `ghcr.io/mikesydo/preview-app:pr-<number>`.
2. Argo CD ApplicationSet detects the open pull request and creates a new Argo CD Application.
3. The Application deploys the Helm chart into a dedicated namespace (`preview-pr-<number>`).
4. The preview is accessible locally at `http://pr-<number>.localhost:8081`.

When the pull request is closed or merged:
1. The ApplicationSet removes the Application automatically (auto-prune enabled).
2. The namespace and all deployed resources are deleted.

## Prerequisites

### 1. GitHub Token Secret
The ApplicationSet Pull Request generator needs a GitHub token to poll for open PRs.
Create the secret in the `argocd` namespace before applying the ApplicationSet:

```bash
kubectl create secret generic github-token \
  --from-literal=token=<YOUR_GITHUB_PAT> \
  -n argocd
```

The token needs `repo` scope (or `public_repo` for public repositories) to list pull requests.

> **Note:** Do not commit the token value. Only the secret reference is stored in the manifest.

### 2. Ingress Hosts (local)
For local testing, each PR preview will use the host `pr-<number>.localhost`.
Because DNS resolution for `*.localhost` is not automatic on all OS configurations, you may need to add each host manually to `/etc/hosts`:

```
127.0.0.1 pr-1.localhost
127.0.0.1 pr-2.localhost
```

Or use `curl` with the `--resolve` flag:
```bash
curl -i --resolve "pr-1.localhost:8081:127.0.0.1" http://pr-1.localhost:8081
```

## Applying the ApplicationSet

```bash
kubectl apply -f argocd/applicationset-preview.yaml
```

Argo CD will begin polling GitHub every 30 seconds for open pull requests.

## Verifying a Preview Environment

```bash
# List all preview Applications created by the ApplicationSet
kubectl get applications -n argocd -l argocd.argoproj.io/application-set-name=preview-environments

# Check the namespace for a specific PR
kubectl get pods -n preview-pr-1

# Test access (after adding host to /etc/hosts)
curl -i http://pr-1.localhost:8081
```

## Cleanup

When a PR is closed, Argo CD will automatically delete the Application and prune all resources in the PR namespace.

To verify cleanup:
```bash
kubectl get namespace preview-pr-1
# Should return: Error from server (NotFound)
```
