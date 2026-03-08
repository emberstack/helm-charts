# Azurite Helm Chart

A Helm chart for deploying [Azurite](https://github.com/Azure/Azurite) (Azure Storage Emulator) on Kubernetes. Provides Blob, Queue, and Table storage services.

## Installation

### Using OCI registry (recommended)

```bash
helm install azurite oci://ghcr.io/emberstack/helm-charts/azurite
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install azurite emberstack/azurite
```

## Parameters

### Global parameters

| Parameter | Description | Default |
|---|---|---|
| `global.image.registry` | Override image registry for all containers | `""` |
| `global.image.tag` | Override image tag for all containers | `""` |
| `global.image.pullSecrets` | Pull secrets for all containers | `[]` |
| `global.storageClass` | Override storage class | `""` |

### Common parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `extraObjects` | Extra Kubernetes objects to deploy | `[]` |

### Image parameters

| Parameter | Description | Default |
|---|---|---|
| `image.registry` | Image registry | `mcr.microsoft.com` |
| `image.repository` | Image repository | `azure-storage/azurite` |
| `image.tag` | Image tag | `latest` |
| `image.digest` | Image digest (overrides tag) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Image pull secrets | `[]` |

### Test image parameters

| Parameter | Description | Default |
|---|---|---|
| `testImage.registry` | Test image registry | `docker.io` |
| `testImage.repository` | Test image repository | `busybox` |
| `testImage.tag` | Test image tag | `latest` |
| `testImage.pullPolicy` | Test image pull policy | `IfNotPresent` |

### Azurite configuration

| Parameter | Description | Default |
|---|---|---|
| `configuration.blobEnabled` | Enable Blob service (port 10000) | `true` |
| `configuration.queueEnabled` | Enable Queue service (port 10001) | `true` |
| `configuration.tableEnabled` | Enable Table service (port 10002) | `true` |
| `configuration.loose` | Relaxed API validation | `true` |
| `configuration.disableProductStyleUrl` | Use path-style URLs | `true` |
| `configuration.skipApiVersionCheck` | Skip API version check | `true` |
| `configuration.inMemoryPersistence` | In-memory mode (no disk, ignores PVC) | `false` |
| `configuration.debugLog` | Debug log file path (empty = stdout) | `""` |
| `configuration.certPath` | HTTPS certificate PEM/PFX path | `""` |
| `configuration.keyPath` | HTTPS key PEM path | `""` |
| `configuration.certPassword` | PFX certificate password | `""` |
| `configuration.oauth` | OAuth support (set to "basic" to enable) | `""` |
| `configuration.silent` | Disable access log output | `false` |
| `configuration.disableTelemetry` | Disable telemetry collection | `false` |
| `configuration.extentMemoryLimit` | In-memory extent limit in MB (with inMemoryPersistence) | `""` |
| `configuration.extraArgs` | Extra CLI arguments | `[]` |

### Deployment parameters

| Parameter | Description | Default |
|---|---|---|
| `deployment.enabled` | Create a Deployment | `true` |
| `deployment.replicaCount` | Number of replicas | `1` |
| `deployment.revisionHistoryLimit` | Revision history limit | `3` |
| `deployment.updateStrategy.type` | Update strategy | `Recreate` |
| `deployment.annotations` | Deployment annotations | `{}` |
| `deployment.labels` | Deployment labels | `{}` |
| `deployment.minReadySeconds` | Min ready seconds | `""` |

### Diagnostic mode

| Parameter | Description | Default |
|---|---|---|
| `diagnosticMode.enabled` | Override command, args, and probes for debugging | `false` |
| `diagnosticMode.command` | Diagnostic command | `["sleep"]` |
| `diagnosticMode.args` | Diagnostic args | `["infinity"]` |

### Container parameters

| Parameter | Description | Default |
|---|---|---|
| `command` | Override container command | `[]` |
| `args` | Override container args | `[]` |
| `extraContainerPorts` | Extra container ports | `[]` |
| `resources` | CPU/memory resource requests/limits | `{}` |
| `resourcesPreset` | Resource preset (nano, micro, small, medium, large, xlarge, 2xlarge) | `""` |
| `lifecycleHooks` | Container lifecycle hooks | `{}` |

### Probes

| Parameter | Description | Default |
|---|---|---|
| `livenessProbe` | Liveness probe configuration | tcpSocket on `blob`, 10s initial delay |
| `readinessProbe` | Readiness probe configuration | tcpSocket on `blob`, 5s initial delay |
| `startupProbe` | Startup probe configuration | tcpSocket on `blob`, 5s initial delay |
| `customLivenessProbe` | Override liveness probe entirely | `{}` |
| `customReadinessProbe` | Override readiness probe entirely | `{}` |
| `customStartupProbe` | Override startup probe entirely | `{}` |

### Environment variables

| Parameter | Description | Default |
|---|---|---|
| `extraEnvVars` | Extra environment variables | `[]` |
| `extraEnvVarsCM` | ConfigMap with extra env vars | `""` |
| `extraEnvVarsSecret` | Secret with extra env vars | `""` |

### Volume parameters

| Parameter | Description | Default |
|---|---|---|
| `extraVolumeMounts` | Extra volume mounts for the container | `[]` |
| `extraVolumes` | Extra volumes for the pod | `[]` |

### Pod parameters

| Parameter | Description | Default |
|---|---|---|
| `podLabels` | Extra pod labels | `{}` |
| `podAnnotations` | Extra pod annotations | `{}` |
| `podSecurityContext.enabled` | Enable pod security context | `true` |
| `podSecurityContext.fsGroup` | Pod filesystem group | `1000` |
| `podSecurityContext.seccompProfile.type` | Seccomp profile type | `RuntimeDefault` |
| `containerSecurityContext.enabled` | Enable container security context | `true` |
| `containerSecurityContext.readOnlyRootFilesystem` | Read-only root filesystem | `true` |
| `containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `containerSecurityContext.capabilities.drop` | Dropped Linux capabilities | `["ALL"]` |
| `podAffinityPreset` | Pod affinity preset (soft, hard) | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset (soft, hard) | `""` |
| `nodeAffinityPreset.type` | Node affinity preset type (soft, hard) | `""` |
| `nodeAffinityPreset.key` | Node affinity label key | `""` |
| `nodeAffinityPreset.values` | Node affinity label values | `[]` |
| `affinity` | Full affinity rules (overrides presets) | `{}` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `topologySpreadConstraints` | Topology spread constraints | `[]` |
| `priorityClassName` | Priority class name | `""` |
| `schedulerName` | Scheduler name | `""` |
| `terminationGracePeriodSeconds` | Termination grace period | `""` |
| `dnsPolicy` | DNS policy | `""` |
| `dnsConfig` | DNS configuration | `{}` |
| `hostNetwork` | Use host network | `false` |
| `initContainers` | Init containers | `[]` |
| `sidecars` | Sidecar containers | `[]` |

### Service account parameters

| Parameter | Description | Default |
|---|---|---|
| `serviceAccount.create` | Create a ServiceAccount | `true` |
| `serviceAccount.name` | ServiceAccount name | `""` |
| `serviceAccount.annotations` | ServiceAccount annotations | `{}` |
| `serviceAccount.automountServiceAccountToken` | Auto-mount API token | `false` |

### RBAC parameters

| Parameter | Description | Default |
|---|---|---|
| `rbac.create` | Create RBAC resources | `false` |
| `rbac.clusterRole.rules` | ClusterRole rules | `[]` |
| `rbac.role.rules` | Role rules | `[]` |

### Service parameters

| Parameter | Description | Default |
|---|---|---|
| `service.enabled` | Create a Service | `true` |
| `service.type` | Service type | `ClusterIP` |
| `service.blobPort` | Blob service port | `10000` |
| `service.queuePort` | Queue service port | `10001` |
| `service.tablePort` | Table service port | `10002` |
| `service.clusterIP` | Cluster IP | `""` |
| `service.loadBalancerIP` | Load balancer IP | `""` |
| `service.loadBalancerSourceRanges` | Load balancer source ranges | `[]` |
| `service.externalTrafficPolicy` | External traffic policy | `""` |
| `service.annotations` | Service annotations | `{}` |
| `service.labels` | Service labels | `{}` |
| `service.extraPorts` | Extra service ports | `[]` |

### Ingress parameters

| Parameter | Description | Default |
|---|---|---|
| `ingress.enabled` | Create an Ingress | `false` |
| `ingress.ingressClassName` | Ingress class name | `""` |
| `ingress.hostname` | Ingress hostname | `""` |
| `ingress.path` | Ingress path | `/` |
| `ingress.pathType` | Ingress path type | `Prefix` |
| `ingress.tls` | Enable TLS | `false` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.labels` | Ingress labels | `{}` |
| `ingress.extraHosts` | Extra ingress hosts | `[]` |
| `ingress.extraTls` | Extra TLS configuration | `[]` |
| `ingress.extraRules` | Extra ingress rules | `[]` |

### HTTPRoute parameters (Gateway API)

| Parameter | Description | Default |
|---|---|---|
| `httpRoute.enabled` | Create an HTTPRoute | `false` |
| `httpRoute.parentRefs` | Gateway references | `[]` |
| `httpRoute.hostnames` | Route hostnames | `[]` |
| `httpRoute.rules` | Routing rules (backendRefs default to blob port) | `[]` |
| `httpRoute.annotations` | HTTPRoute annotations | `{}` |
| `httpRoute.labels` | HTTPRoute labels | `{}` |
| `httpRoute.httpRedirect.enabled` | Create HTTP→HTTPS redirect companion route | `false` |
| `httpRoute.httpRedirect.parentRefs` | Redirect route parent refs (auto-derived if empty) | `[]` |
| `httpRoute.httpRedirect.hostnames` | Redirect route hostnames | `[]` |
| `httpRoute.httpRedirect.annotations` | Redirect route annotations | `{}` |
| `httpRoute.httpRedirect.labels` | Redirect route labels | `{}` |
| `httpRoute.httpRedirect.scheme` | Redirect scheme | `https` |
| `httpRoute.httpRedirect.statusCode` | Redirect status code | `301` |
| `httpRoute.httpRedirect.port` | Redirect port | `""` |
| `httpRoute.httpRedirect.path` | Redirect path modifier | `{}` |

### PodDisruptionBudget parameters

| Parameter | Description | Default |
|---|---|---|
| `pdb.enabled` | Create a PodDisruptionBudget | `false` |
| `pdb.minAvailable` | Min available pods | `""` |
| `pdb.maxUnavailable` | Max unavailable pods | `1` |

### NetworkPolicy parameters

| Parameter | Description | Default |
|---|---|---|
| `networkPolicy.enabled` | Create a NetworkPolicy | `false` |
| `networkPolicy.policyTypes` | Policy types | `["Ingress", "Egress"]` |
| `networkPolicy.ingress` | Ingress rules | `[]` |
| `networkPolicy.egress` | Egress rules | `[]` |
| `networkPolicy.allowExternalDNS` | Allow DNS egress (UDP/TCP 53) | `true` |

### ServiceMonitor parameters (Prometheus Operator)

| Parameter | Description | Default |
|---|---|---|
| `serviceMonitor.enabled` | Create a ServiceMonitor | `false` |
| `serviceMonitor.namespace` | ServiceMonitor namespace | `""` |
| `serviceMonitor.port` | Metrics port name | `blob` |
| `serviceMonitor.path` | Metrics path | `/metrics` |
| `serviceMonitor.interval` | Scrape interval | `30s` |
| `serviceMonitor.scrapeTimeout` | Scrape timeout | `""` |
| `serviceMonitor.labels` | ServiceMonitor labels | `{}` |
| `serviceMonitor.annotations` | ServiceMonitor annotations | `{}` |
| `serviceMonitor.relabelings` | Relabeling configs | `[]` |
| `serviceMonitor.metricRelabelings` | Metric relabeling configs | `[]` |
| `serviceMonitor.honorLabels` | Honor labels | `false` |

### ConfigMap parameters

| Parameter | Description | Default |
|---|---|---|
| `configMap.enabled` | Create a ConfigMap | `false` |
| `configMap.data` | ConfigMap data | `{}` |

### Custom storage accounts

Azurite supports custom storage accounts via the `AZURITE_ACCOUNTS` environment variable. Use `extraEnvVars` (or `extraEnvVarsSecret` for sensitive keys) to configure them:

```yaml
extraEnvVars:
  - name: AZURITE_ACCOUNTS
    value: "myaccount1:a2V5MQ==;myaccount2:a2V5Mg=="
```

Format: `account1:key1[:key2];account2:key1[:key2]` (keys must be base64-encoded).

> **Note:** Setting `AZURITE_ACCOUNTS` disables the default `devstoreaccount1` account.

### Persistence parameters

| Parameter | Description | Default |
|---|---|---|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.resourcePolicy` | PVC resource policy (`"keep"` to preserve on uninstall) | `""` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessModes` | Access modes | `[ReadWriteOnce]` |
| `persistence.size` | PVC size | `8Gi` |
| `persistence.existingClaim` | Use existing PVC | `""` |
| `persistence.mountPath` | Mount path (also used as azurite data dir) | `/data` |
| `persistence.subPath` | Volume sub-path | `""` |
| `persistence.annotations` | PVC annotations | `{}` |
