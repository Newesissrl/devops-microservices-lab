# Kubernetes Deployment Guide

## Prerequisites

### 1. Create GitHub Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes:
   - `read:packages` - Download packages from GitHub Container Registry
4. Copy the generated token

### 2. Create Docker Registry Secret

```bash
# Create the secret with your GitHub credentials
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_PAT \
  --namespace=expenses

# Or create from Docker config file
kubectl create secret generic ghcr-secret \
  --from-file=.dockerconfigjson=$HOME/.docker/config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace=expenses
```

### 3. Update Image Names

Edit the following files and replace `your-org/your-repo` with your actual GitHub repository:

- `backend.yaml`
- `frontend.yaml` 
- `processor.yaml`
- `lakepublisher.yaml`

Example: `ghcr.io/myorg/expenses-app/backend:latest`

## Deployment

```bash
# Apply all manifests
kubectl apply -f devops/kubernetes/

# Check deployment status
kubectl get all -n expenses

# Check pods
kubectl get pods -n expenses

# View logs
kubectl logs -f deployment/backend -n expenses
```

## Access Application

```bash
# Get frontend service external IP
kubectl get svc frontend-service -n expenses

# Port forward for local access
kubectl port-forward svc/frontend-service 8080:80 -n expenses
```

## Troubleshooting

```bash
# Check image pull issues
kubectl describe pod POD_NAME -n expenses

# Check secret
kubectl get secret ghcr-secret -n expenses -o yaml

# Test image pull manually
docker pull ghcr.io/your-org/your-repo/backend:latest
```