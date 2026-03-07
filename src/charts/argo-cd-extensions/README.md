# Argo CD Helm Extensions

This chart provides templates for Argo CD CRDs. It can be used as the base for dynamic resources.

> Requirements: Argo CD installed in the cluster.

## Installation

### Using OCI registry (recommended)

```bash
helm install argo-cd-extensions oci://ghcr.io/emberstack/helm-charts/argo-cd-extensions
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install argo-cd-extensions emberstack/argo-cd-extensions
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `applications` | Array of Argo CD Applications | `[]` |
| `appProjects` | Array of Argo CD AppProjects | `[]` |
