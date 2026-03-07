# Core Helm Extensions

This chart provides templates for core Kubernetes resources such as ConfigMaps and Secrets. It can be used as the base for dynamic resources.

## Installation

### Using OCI registry (recommended)

```bash
helm install core-extensions oci://ghcr.io/emberstack/helm-charts/core-extensions
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install core-extensions emberstack/core-extensions
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `configMaps` | Array of ConfigMaps | `[]` |
| `secrets` | Array of Secrets | `[]` |
