# Preview Environment Platform

A GitOps-based preview environment platform for pull requests using GitHub Actions, Argo CD, Helm, and Kubernetes.

This repository serves two purposes:

1. A **local template** for running per-PR preview environments on a local Kubernetes cluster.
2. A foundation for a future **hosted preview platform** deployed in the cloud.

## Overview

For every pull request, the platform can:

- Build and push a preview Docker image to GHCR.
- Create or update a PR comment with the preview URL.
- Publish a GitHub status check with a direct link to the preview environment.
- Deploy a dedicated preview environment through Argo CD and Helm.
- Remove environments automatically when PRs are closed.
- Optionally clean up stale preview environments after a TTL period.

## Lifecycle
See preview environment lifecycle in following doc:
- [preview-lifecycle.md](./docs/preview-lifecycle.md) 

## Preview label requirement

Preview environments are created **only** for pull requests that have the `preview` label.

This behavior is controlled by the Argo CD `ApplicationSet` pull request generator. If a pull request does not have the `preview` label, no preview namespace, application, or ingress will be created. GitHub workflow steps may still run, but the actual Kubernetes preview environment is gated by the label.

Typical flow:

1. Open or update a pull request.
2. Add the `preview` label.
3. Argo CD detects the labeled PR and creates the preview environment.
4. Remove the label or close the PR to let the environment be cleaned up on the next reconcile loop.

## Architecture

```text
Pull Request opened or updated
        ↓
GitHub Actions builds and pushes image to GHCR
        ↓
Argo CD ApplicationSet detects open PR with `preview` label
        ↓
Helm deploys preview app into a dedicated namespace
        ↓
Ingress exposes preview URL
        ↓
GitHub PR comment + status check link to the environment
```

## Repository Structure

```text
.github/workflows/       GitHub Actions workflows
argocd/                  Argo CD manifests and ApplicationSets
helm/preview-app/        Helm chart for preview deployments
scripts/                 Local bootstrap and utility scripts
docs/                    Technical and operational documentation
examples/                Example app or sample assets
```

## Features

- Per-PR isolated preview environments
- GitOps deployment flow with Argo CD
- Helm-based application templating
- Automatic PR comments with preview links
- GitHub commit status integration
- Label-gated preview creation
- Local development support
- Extensible path to cloud deployment on EKS or GKE

## Requirements

- Kubernetes cluster
- kubectl
- Helm
- Argo CD
- Docker
- GitHub repository with Actions enabled
- GHCR access for pushing images
  
## Local Setup

See the following docs:

- [onboarding.md](./docs/onboarding.md)
- [local-setup.md](./docs/local-setup.md)
- [gitops-flow.md](./docs/gitops-flow.md) 

## Quick Start

1. Clone this repository.
2. Bootstrap the local environment.
3. Install Argo CD.
4. Apply the ApplicationSet.
5. Open a pull request in the connected repository.
6. Add the `preview` label to the PR.
7. Verify the image build, Argo CD sync, and preview comment.

Example scripts:

```bash
./scripts/bootstrap-local.sh
./scripts/install-argocd.sh
```

## TTL Cleanup

This repository can support scheduled cleanup of inactive preview environments.

Typical behavior:

- If a labeled PR is open but inactive for N days, the preview environment is removed.
- When a new commit is pushed to the same labeled PR, Argo CD can recreate the preview environment automatically after the image is rebuilt.

## Roadmap

The next milestones focus on turning this local template into a cloud-ready, reusable preview platform.

- Cloud deployment on EKS
- Hosted multi-repository platform
- GitHub App integration
- Better lifecycle policies for stale environments
- Organization-level onboarding flow

## Contributing

Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before submitting changes.

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE).
