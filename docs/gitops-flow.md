# GitOps Foundation Flow with Argo CD

This document describes how to set up Argo CD in the local cluster and manage applications declaratively using GitOps.

## Argo CD Installation

1. Run the installation script to create the `argocd` namespace and apply the Argo CD manifests:
   ```bash
   bash scripts/install-argocd.sh
   ```
2. The script will wait for all Argo CD deployments (server, repo-server, applicationset-controller) to become healthy.

## Accessing the Argo CD UI

1. Get the auto-generated administrator password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
   ```
2. Port-forward the `argocd-server` service to your local machine:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
3. Open `https://localhost:8080` in your browser. Log in with:
   - **Username:** `admin`
   - **Password:** (retrieved in step 1)

## Declarative Configuration (GitOps)

We manage environments using Argo CD Projects and Applications.

### 1. AppProject
The [project.yaml](file:///c:/Users/misha/Projects/Preview-Environment-Platform/argocd/project.yaml) resource defines access control:
- Restricts target cluster to `https://kubernetes.default.svc`.
- Allows creating resources in any namespace (to support dynamic PR preview namespaces later).

Apply it:
```bash
kubectl apply -f argocd/project.yaml
```

### 2. Application
The [application.yaml](file:///c:/Users/misha/Projects/Preview-Environment-Platform/argocd/application.yaml) resource configures the deployment of the Helm chart:
- Source repo: `https://github.com/MikeSydo/Preview-Environment-Platform.git`
- Source path: `helm/preview-app`
- Target Namespace: `preview-test`
- Automated Sync: Enabled with prune and selfHeal.

Apply it:
```bash
kubectl apply -f argocd/application.yaml
```

Once applied, Argo CD will sync the Helm chart from the remote repository branch and reconcile the state.
