# Microsoft SQL Server Helm Chart

A Helm chart for deploying Microsoft SQL Server 2025 on Kubernetes.

## Installation

### Using OCI registry (recommended)

```bash
helm install mssql oci://ghcr.io/emberstack/helm-charts/mssql \
  --set configuration.acceptEula=true \
  --set configuration.saPassword="YourStr0ngP@ssword"
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install mssql emberstack/mssql \
  --set configuration.acceptEula=true \
  --set configuration.saPassword="YourStr0ngP@ssword"
```

## Global Parameters

| Parameter | Description | Default |
|---|---|---|
| `global.image.registry` | Override image registry for all containers | `""` |
| `global.image.tag` | Override image tag for all containers | `""` |
| `global.image.pullSecrets` | Pull secrets for all containers | `[]` |
| `global.podLabels` | Labels added to all pods across subcharts | `{}` |
| `global.podAnnotations` | Annotations added to all pods across subcharts | `{}` |
| `global.extraEnvVars` | Env vars injected into all containers across subcharts | `[]` |
| `global.serviceAccount.create` | Override service account creation across subcharts | `true` |
| `global.serviceAccount.name` | Override service account name across subcharts | `""` |
| `global.storageClass` | Override storage class | `""` |

## Common Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `extraObjects` | Extra Kubernetes resources to deploy | `[]` |

## Image Parameters

| Parameter | Description | Default |
|---|---|---|
| `image.registry` | Image registry | `mcr.microsoft.com` |
| `image.repository` | Image repository | `mssql/server` |
| `image.tag` | Image tag | `2025-latest` |
| `image.digest` | Image digest (overrides tag) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Image pull secrets | `[]` |

## SQL Server Configuration

| Parameter | Description | Default |
|---|---|---|
| `configuration.acceptEula` | Accept the SQL Server EULA (required) | `false` |
| `configuration.edition` | SQL Server edition | `Developer` |
| `configuration.saPassword` | SA password (required unless existingSecret is set) | `""` |
| `configuration.existingSecret` | Use an existing secret for SA password | `""` |
| `configuration.existingSecretKey` | Key in the existing secret | `saPassword` |
| `configuration.collation` | Database collation | `""` |
| `configuration.lcid` | Language ID (e.g. 1036 for French) | `""` |
| `configuration.memoryLimitMb` | Max memory in MB | `""` |
| `configuration.tcpPort` | TCP port | `""` |
| `configuration.agentEnabled` | Enable SQL Server Agent | `false` |
| `configuration.hadrEnabled` | Enable Always On Availability Groups | `false` |
| `configuration.dataDir` | Custom data file directory | `""` |
| `configuration.logDir` | Custom log file directory | `""` |
| `configuration.backupDir` | Custom backup directory | `""` |
| `configuration.dumpDir` | Custom dump directory | `""` |

### Supported Editions

| Value | Description |
|---|---|
| `Developer` | SQL Server Developer edition (free, non-production) |
| `Express` | SQL Server Express edition |
| `Standard` | SQL Server Standard edition |
| `Enterprise` | SQL Server Enterprise (CAL-based, legacy) |
| `EnterpriseCore` | SQL Server Enterprise Core edition |
| `StandardDeveloper` | SQL Server 2025 Standard Developer edition |
| `EnterpriseDeveloper` | SQL Server 2025 Enterprise Developer edition |
| `Evaluation` | SQL Server Evaluation edition |

## Deployment Parameters

| Parameter | Description | Default |
|---|---|---|
| `deployment.enabled` | Deploy as Deployment | `true` |
| `deployment.replicaCount` | Number of replicas | `1` |
| `deployment.revisionHistoryLimit` | Revision history limit | `3` |
| `deployment.updateStrategy.type` | Update strategy | `RollingUpdate` |
| `deployment.annotations` | Deployment annotations | `{}` |
| `deployment.labels` | Deployment labels | `{}` |
| `deployment.minReadySeconds` | Min seconds before pod is ready | `""` |

## Diagnostic Mode

| Parameter | Description | Default |
|---|---|---|
| `diagnosticMode.enabled` | Enable diagnostic mode | `false` |
| `diagnosticMode.command` | Diagnostic command | `["sleep"]` |
| `diagnosticMode.args` | Diagnostic args | `["infinity"]` |

## Container Parameters

| Parameter | Description | Default |
|---|---|---|
| `command` | Override container command | `[]` |
| `args` | Override container args | `[]` |
| `containerPort` | SQL Server port | `1433` |
| `extraContainerPorts` | Additional container ports | `[]` |
| `resources` | Resource requests and limits | `{}` |
| `resourcesPreset` | Resource preset (nano/micro/small/medium/large/xlarge/2xlarge) | `""` |
| `lifecycleHooks` | Lifecycle hooks | `{}` |
| `extraEnvVars` | Additional environment variables | `[]` |
| `extraEnvVarsCM` | ConfigMap name for envFrom | `""` |
| `extraEnvVarsSecret` | Secret name for envFrom | `""` |
| `extraVolumeMounts` | Additional volume mounts | `[]` |
| `extraVolumes` | Additional volumes | `[]` |

## Probes

Default probes use TCP on port 1433. Override with `custom*Probe` or disable with `diagnosticMode`.

| Parameter | Description | Default |
|---|---|---|
| `livenessProbe` | Default liveness probe | tcpSocket on mssql |
| `customLivenessProbe` | Override liveness probe | `{}` |
| `readinessProbe` | Default readiness probe | tcpSocket on mssql |
| `customReadinessProbe` | Override readiness probe | `{}` |
| `startupProbe` | Default startup probe | tcpSocket on mssql |
| `customStartupProbe` | Override startup probe | `{}` |

## Pod Parameters

| Parameter | Description | Default |
|---|---|---|
| `podLabels` | Additional pod labels | `{}` |
| `podAnnotations` | Additional pod annotations | `{}` |
| `podSecurityContext` | Pod security context | `{enabled: true, fsGroup: 10001}` |
| `containerSecurityContext` | Container security context | `{enabled: true, runAsNonRoot: true, runAsUser: 10001, allowPrivilegeEscalation: false}` |
| `podAffinityPreset` | Pod affinity preset (soft/hard) | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset (soft/hard) | `""` |
| `nodeAffinityPreset.type` | Node affinity preset type | `""` |
| `nodeAffinityPreset.key` | Node affinity label key | `""` |
| `nodeAffinityPreset.values` | Node affinity label values | `[]` |
| `affinity` | Full affinity override | `{}` |
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

## Service Account

| Parameter | Description | Default |
|---|---|---|
| `serviceAccount.create` | Create a ServiceAccount | `true` |
| `serviceAccount.name` | ServiceAccount name | `""` (generated) |
| `serviceAccount.annotations` | ServiceAccount annotations | `{}` |
| `serviceAccount.automountServiceAccountToken` | Automount API token | `false` |

## RBAC

| Parameter | Description | Default |
|---|---|---|
| `rbac.create` | Create RBAC resources | `false` |
| `rbac.clusterRole.rules` | ClusterRole rules | `[]` |
| `rbac.role.rules` | Role rules (namespace-scoped) | `[]` |

## Service

| Parameter | Description | Default |
|---|---|---|
| `service.enabled` | Create a Service | `true` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `1433` |
| `service.targetPort` | Target port | `mssql` |
| `service.nodePort` | NodePort (when type=NodePort) | `""` |
| `service.clusterIP` | Cluster IP (use `None` for headless) | `""` |
| `service.loadBalancerIP` | Load balancer IP | `""` |
| `service.loadBalancerSourceRanges` | Load balancer source ranges | `[]` |
| `service.externalTrafficPolicy` | External traffic policy | `""` |
| `service.annotations` | Service annotations | `{}` |
| `service.labels` | Service labels | `{}` |
| `service.extraPorts` | Additional service ports | `[]` |

## PodDisruptionBudget

| Parameter | Description | Default |
|---|---|---|
| `pdb.enabled` | Enable PDB | `false` |
| `pdb.minAvailable` | Minimum available pods | `""` |
| `pdb.maxUnavailable` | Maximum unavailable pods | `1` |

## NetworkPolicy

| Parameter | Description | Default |
|---|---|---|
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |
| `networkPolicy.policyTypes` | Policy types | `[Ingress, Egress]` |
| `networkPolicy.ingress` | Ingress rules | `[]` |
| `networkPolicy.egress` | Egress rules | `[]` |
| `networkPolicy.allowExternalDNS` | Allow DNS egress | `true` |

## ServiceMonitor (Prometheus)

| Parameter | Description | Default |
|---|---|---|
| `serviceMonitor.enabled` | Enable ServiceMonitor | `false` |
| `serviceMonitor.namespace` | ServiceMonitor namespace | `""` |
| `serviceMonitor.port` | Metrics port | `mssql` |
| `serviceMonitor.path` | Metrics path | `/metrics` |
| `serviceMonitor.interval` | Scrape interval | `30s` |
| `serviceMonitor.scrapeTimeout` | Scrape timeout | `""` |
| `serviceMonitor.labels` | Additional labels | `{}` |
| `serviceMonitor.annotations` | Additional annotations | `{}` |
| `serviceMonitor.relabelings` | Relabeling rules | `[]` |
| `serviceMonitor.metricRelabelings` | Metric relabeling rules | `[]` |
| `serviceMonitor.honorLabels` | Honor labels | `false` |

## ConfigMap

| Parameter | Description | Default |
|---|---|---|
| `configMap.enabled` | Create a ConfigMap | `false` |
| `configMap.data` | ConfigMap data (supports template expressions) | `{}` |

## Persistence

| Parameter | Description | Default |
|---|---|---|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessModes` | Access modes | `[ReadWriteOnce]` |
| `persistence.size` | PVC size | `8Gi` |
| `persistence.existingClaim` | Use existing PVC | `""` |
| `persistence.mountPath` | Mount path | `/var/opt/mssql` |
| `persistence.subPath` | Volume sub-path | `""` |
| `persistence.annotations` | PVC annotations | `{}` |
