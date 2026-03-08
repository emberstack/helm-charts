# cert-manager Helm Extensions

This chart provides templates for cert-manager CRDs. It can be used as the base for dynamic resources.

> Requirements: cert-manager installed in the cluster.

## Installation

### Using OCI registry (recommended)

```bash
helm install cert-manager-extensions oci://ghcr.io/emberstack/helm-charts/cert-manager-extensions
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install cert-manager-extensions emberstack/cert-manager-extensions
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `issuers` | Map of Issuers | `{}` |
| `clusterIssuers` | Map of ClusterIssuers | `{}` |
| `certificates` | Map of Certificates (keyed by name) | `{}` |
