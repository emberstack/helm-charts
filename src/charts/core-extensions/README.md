# Core Helm Extensions

This chart provides templates for core Kubernetes resources. It can be used as the base for dynamic resources.

Verified against **Kubernetes v1.36** (`core/v1` and `scheduling.k8s.io/v1`). No additional CRDs are required.

| Kind | apiVersion | Values key | Scope |
|---|---|---|---|
| `ConfigMap` | `v1` | `configMaps` | Namespaced |
| `Secret` | `v1` | `secrets` | Namespaced |
| `ServiceAccount` | `v1` | `serviceAccounts` | Namespaced |
| `Namespace` | `v1` | `namespaces` | Cluster |
| `ResourceQuota` | `v1` | `resourceQuotas` | Namespaced |
| `LimitRange` | `v1` | `limitRanges` | Namespaced |
| `PriorityClass` | `scheduling.k8s.io/v1` | `priorityClasses` | Cluster |

Every section is a **list**; each entry needs its own `name` and is opt-in via `enabled: true`.

### Naming

Resources are named `<release>-<chart>-<name>`. Set `fullnameOverride` on an entry to control the name
exactly — you almost always want that for `namespaces` and `priorityClasses`, whose names are meaningful
cluster-wide. Quote names that YAML would read as booleans (`"off"`, `"no"`, `"yes"`).

### Templating

`data`, `stringData`, `binaryData`, `hard`, `scopes`, `finalizers` and ServiceAccount `secrets` are rendered
as Helm templates, so `"{{ .Release.Namespace }}"` works inside their values.

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
| `configMaps` | List of ConfigMaps | `[]` |
| `secrets` | List of Secrets | `[]` |
| `serviceAccounts` | List of ServiceAccounts | `[]` |
| `namespaces` | List of Namespaces | `[]` |
| `resourceQuotas` | List of ResourceQuotas | `[]` |
| `limitRanges` | List of LimitRanges | `[]` |
| `priorityClasses` | List of PriorityClasses | `[]` |

Per-entry keys common to every kind: `name` (required), `enabled`, `fullnameOverride`, `labels`, `annotations`,
and `namespace` for the namespaced kinds.

See [values.yaml](values.yaml) for the full annotated field reference.

## Usage Examples

### ConfigMap and Secret

```yaml
configMaps:
  - name: app-config
    enabled: true
    data:
      LOG_LEVEL: info
      ENVIRONMENT: "{{ .Release.Namespace }}"

secrets:
  - name: app-secret
    enabled: true
    type: Opaque
    stringData:
      API_KEY: s3cr3t
```

### Immutable ConfigMap

```yaml
configMaps:
  - name: pinned
    enabled: true
    immutable: true
    data:
      VERSION: "1.4.2"
```

### ServiceAccount with an image pull secret

```yaml
serviceAccounts:
  - name: app
    enabled: true
    automountServiceAccountToken: false
    imagePullSecrets:
      - name: registry-credentials
```

### Namespace with an exact name

```yaml
namespaces:
  - name: team-a
    enabled: true
    fullnameOverride: team-a
    labels:
      team: a
```

### ResourceQuota and LimitRange

```yaml
resourceQuotas:
  - name: team-a-quota
    enabled: true
    hard:
      requests.cpu: "4"
      requests.memory: 8Gi
      pods: "50"

limitRanges:
  - name: defaults
    enabled: true
    limits:
      - type: Container
        default:
          cpu: 500m
          memory: 512Mi
        defaultRequest:
          cpu: 100m
          memory: 128Mi
```

### PriorityClass

```yaml
priorityClasses:
  - name: high
    enabled: true
    fullnameOverride: high-priority
    value: 1000000
    globalDefault: false
    description: Critical workloads
    preemptionPolicy: PreemptLowerPriority
```
