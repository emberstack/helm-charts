# Argo CD Helm Extensions

This chart provides templates for Argo CD CRDs. It can be used as the base for dynamic resources.

> Requirements: [Argo CD](https://argo-cd.readthedocs.io/) installed in the cluster.

Templates target `argoproj.io/v1alpha1` as shipped with **Argo CD v3.5.1**.

| Kind | Values key | Notes |
|---|---|---|
| `AppProject` | `appProjects` | |
| `Application` | `applications` | exactly one of `source` / `sources` |
| `ApplicationSet` | `applicationSets` | `generators` and `template` both required |

That is the complete `argoproj.io` CRD set installed by Argo CD. Every section is a **list**; each entry needs
its own `name` and is opt-in via `enabled: true`.

Resources are named `<release>-<chart>-<name>`; set `fullnameOverride` for an exact name. Use `namespace` on an
entry to place the resource in the namespace your Argo CD instance watches (commonly `argocd`).

### Argo CD placeholders are passed through verbatim

`ApplicationSet` `template` blocks and `generators` are emitted as-is, so Argo CD's own placeholders — Go
template (`{{ .cluster }}`) or legacy fasttemplate (`{{cluster}}`) — survive untouched. The chart does not
attempt to render them as Helm templates.

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
| `appProjects` | List of AppProjects | `[]` |
| `applications` | List of Applications | `[]` |
| `applicationSets` | List of ApplicationSets | `[]` |

Per-entry keys: `name` (required), `enabled`, `fullnameOverride`, `namespace`, `labels`, `annotations`.

See [values.yaml](values.yaml) for the full annotated field reference.

## Upgrade notes

- **`revisionHistoryLimit: 0` is now honoured.** Earlier versions dropped it (a falsy check), so Argo CD
  fell back to its default of 10. If you set 0 and relied on that accident, remove the key.
- **`destination.server` and `destination.name` are now rejected when both are set.** Argo CD treats them as
  mutually exclusive; earlier versions silently preferred `server`. Set exactly one.
- **`source`, `sources` and `sourceHydrator` are three mutually exclusive alternatives.** Earlier versions
  silently ignored `sources` when `source` was also set, and rejected a valid hydrator-only Application.

## Usage Examples

### AppProject

```yaml
appProjects:
  - name: my-project
    enabled: true
    description: My project
    sourceRepos:
      - "https://github.com/my-org/*"
    destinations:
      - server: https://kubernetes.default.svc
        namespace: "my-app-*"
    clusterResourceWhitelist:
      - group: "*"
        kind: "*"
    roles:
      - name: read-only
        policies:
          - "p, proj:my-project:read-only, applications, get, my-project/*, allow"
```

### AppProject with service-account impersonation

```yaml
appProjects:
  - name: impersonated
    enabled: true
    destinationServiceAccounts:
      - server: https://kubernetes.default.svc
        namespace: my-app
        defaultServiceAccount: my-deployer
    permitOnlyProjectScopedClusters: true
```

### Application with automated sync

```yaml
applications:
  - name: my-app
    enabled: true
    namespace: argocd
    finalizers:
      - resources-finalizer.argocd.argoproj.io
    project: default
    source:
      repoURL: https://github.com/my-org/my-repo
      path: manifests
      targetRevision: HEAD
    destination:
      server: https://kubernetes.default.svc
      namespace: my-app
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
```

### Multi-source Application

```yaml
applications:
  - name: multi
    enabled: true
    sources:
      - repoURL: https://github.com/my-org/my-repo
        path: manifests
        targetRevision: HEAD
      - repoURL: https://charts.example.com
        chart: my-chart
        targetRevision: 1.2.3
    destination:
      name: in-cluster
      namespace: my-app
```

### Application using the source hydrator

```yaml
applications:
  - name: hydrated
    enabled: true
    sourceHydrator:
      drySource:
        repoURL: https://github.com/my-org/my-repo
        path: manifests
        targetRevision: main
      syncSource:
        path: manifests
        targetBranch: environments/dev
    destination:
      server: https://kubernetes.default.svc
      namespace: my-app
```

### ApplicationSet with a list generator

```yaml
applicationSets:
  - name: my-appset
    enabled: true
    goTemplate: true
    goTemplateOptions:
      - missingkey=error
    generators:
      - list:
          elements:
            - cluster: dev
              url: https://kubernetes.default.svc
    template:
      metadata:
        name: "{{ .cluster }}-app"
      spec:
        project: default
        source:
          repoURL: https://github.com/my-org/my-repo
          path: manifests
          targetRevision: HEAD
        destination:
          server: "{{ .url }}"
          namespace: my-app
```
