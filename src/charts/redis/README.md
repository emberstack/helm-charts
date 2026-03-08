# Redis Helm Chart

A Helm chart for deploying Redis on Kubernetes with support for standalone, replication, sentinel (HA), and cluster (sharded) architectures.

## Installation

### Using OCI registry (recommended)

```bash
helm install redis oci://ghcr.io/emberstack/helm-charts/redis
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install redis emberstack/redis
```

## Architectures

| Mode | Description | Minimum Pods |
|------|-------------|--------------|
| `standalone` | Single Redis node | 1 |
| `replication` | One master + N replicas (manual failover) | 3 |
| `replication` + `sentinel.enabled` | HA with automatic failover via Sentinel | 3 |
| `cluster` | Sharded across multiple masters with optional replicas | 3 (no replicas) or 6 (with replicas) |

### Standalone

```bash
helm install redis oci://ghcr.io/emberstack/helm-charts/redis \
  --set architecture=standalone
```

### Replication

```bash
helm install redis oci://ghcr.io/emberstack/helm-charts/redis \
  --set architecture=replication
```

### Sentinel (HA)

```bash
helm install redis oci://ghcr.io/emberstack/helm-charts/redis \
  --set architecture=replication \
  --set sentinel.enabled=true
```

With master-discovery service (for non-Sentinel-aware clients):

```bash
helm install redis oci://ghcr.io/emberstack/helm-charts/redis \
  --set architecture=replication \
  --set sentinel.enabled=true \
  --set sentinel.masterService.enabled=true
```

### Cluster (Sharded)

```bash
helm install redis oci://ghcr.io/emberstack/helm-charts/redis \
  --set architecture=cluster \
  --set replicaCount=6 \
  --set cluster.replicaCount=1
```

## Production Hardening

### PodDisruptionBudget

Recommended for all multi-node deployments (replication, sentinel, cluster). Prevents Kubernetes from evicting too many Redis pods simultaneously during node drains or cluster upgrades, which could cause data loss or total outage.

```yaml
pdb:
  enabled: true
  maxUnavailable: 1
```

### Disabling Dangerous Commands

Commands can be disabled by renaming them to empty strings. Note that disabling `CONFIG` will break the redis-exporter metrics sidecar, which calls `CONFIG GET` to collect metrics. Consider using Redis ACLs (Redis 6+) for per-user command restrictions instead of global renames.

```yaml
disableCommands:
  - FLUSHDB
  - FLUSHALL
  - DEBUG
  - KEYS
```

### TLS

```yaml
tls:
  enabled: true
  existingSecret: redis-tls
  certFilename: tls.crt
  certKeyFilename: tls.key
  certCAFilename: ca.crt
```

### NetworkPolicy

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  allowExternalDNS: true
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
| `extraObjects` | Extra Kubernetes resources to deploy | `[]` |
| `clusterDomain` | Kubernetes cluster domain | `cluster.local` |

### Image parameters

| Parameter | Description | Default |
|---|---|---|
| `image.registry` | Redis image registry | `docker.io` |
| `image.repository` | Redis image repository | `redis` |
| `image.tag` | Redis image tag | `8.0.2` |
| `image.digest` | Image digest (overrides tag) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Image pull secrets | `[]` |
| `testImage.registry` | Test image registry (overrides image.registry for tests) | `""` |
| `testImage.repository` | Test image repository | `""` |
| `testImage.tag` | Test image tag | `""` |
| `testImage.pullPolicy` | Test image pull policy | `""` |

### Architecture

| Parameter | Description | Default |
|---|---|---|
| `architecture` | Redis architecture (`standalone`, `replication`, `cluster`) | `standalone` |
| `replicaCount` | Number of Redis pods | `3` |

### Redis configuration

| Parameter | Description | Default |
|---|---|---|
| `config.content` | Base redis.conf content | `bind * -::*`, `appendonly yes` |
| `config.existingConfigMap` | Use existing ConfigMap for config | `""` |
| `config.mountPath` | Config mount path | `/usr/local/etc/redis` |
| `extraConfig` | Extra config appended after config.content | `""` |
| `extraFlags` | Extra redis-server CLI flags | `[]` |
| `disableCommands` | Commands to disable via rename | `[]` |

### Authentication

| Parameter | Description | Default |
|---|---|---|
| `auth.enabled` | Enable password authentication | `true` |
| `auth.password` | Redis password (auto-generated if empty) | `""` |
| `auth.existingSecret` | Use existing secret for password | `""` |
| `auth.existingSecretKey` | Key in existing secret | `redis-password` |
| `auth.sentinel` | Enable sentinel authentication | `false` |

### TLS

| Parameter | Description | Default |
|---|---|---|
| `tls.enabled` | Enable TLS | `false` |
| `tls.port` | TLS port | `6380` |
| `tls.authClients` | Require TLS client certificates | `true` |
| `tls.existingSecret` | TLS certificate secret name | `""` |
| `tls.certFilename` | Certificate filename in secret | `tls.crt` |
| `tls.certKeyFilename` | Key filename in secret | `tls.key` |
| `tls.certCAFilename` | CA filename in secret | `ca.crt` |

### Sentinel parameters

| Parameter | Description | Default |
|---|---|---|
| `sentinel.enabled` | Enable Sentinel | `false` |
| `sentinel.masterName` | Sentinel master name | `mymaster` |
| `sentinel.port` | Sentinel port | `26379` |
| `sentinel.quorum` | Sentinel quorum | `2` |
| `sentinel.downAfterMilliseconds` | Down-after timeout | `5000` |
| `sentinel.failoverTimeout` | Failover timeout | `60000` |
| `sentinel.parallelSyncs` | Parallel syncs after failover | `1` |
| `sentinel.redisShutdownWaitFailover` | Wait for failover on shutdown | `true` |
| `sentinel.image` | Sentinel image override | (inherits from main) |
| `sentinel.resources` | Sentinel container resources | `{}` |
| `sentinel.masterService.enabled` | Enable master-discovery service | `false` |
| `sentinel.masterService.checkInterval` | Master check interval (seconds) | `10` |
| `sentinel.masterService.image.registry` | Pod labeler image registry | `docker.io` |
| `sentinel.masterService.image.repository` | Pod labeler image repository | `curlimages/curl` |
| `sentinel.masterService.image.tag` | Pod labeler image tag | `latest` |
| `sentinel.masterService.image.pullPolicy` | Pod labeler image pull policy | `Always` |

### Cluster parameters

| Parameter | Description | Default |
|---|---|---|
| `cluster.replicaCount` | Replicas per master node | `1` |
| `cluster.announceHostnames` | Use hostnames instead of IPs | `true` |
| `cluster.config.nodeTimeout` | Cluster node timeout | `15000` |
| `cluster.config.requireFullCoverage` | Require full slot coverage | `true` |
| `cluster.initJob.resources` | Cluster init job resources | `{}` |

### StatefulSet parameters

| Parameter | Description | Default |
|---|---|---|
| `statefulSet.revisionHistoryLimit` | Number of old ReplicaSets to retain | `3` |
| `statefulSet.updateStrategy.type` | StatefulSet update strategy type | `RollingUpdate` |
| `statefulSet.podManagementPolicy` | Pod management policy | `OrderedReady` |
| `statefulSet.annotations` | Additional StatefulSet annotations | `{}` |
| `statefulSet.labels` | Additional StatefulSet labels | `{}` |
| `statefulSet.minReadySeconds` | Minimum seconds before pod is considered ready | `""` |

### Diagnostic mode

| Parameter | Description | Default |
|---|---|---|
| `diagnosticMode.enabled` | Enable diagnostic mode (overrides command/args and disables probes) | `false` |
| `diagnosticMode.command` | Command override in diagnostic mode | `["sleep"]` |
| `diagnosticMode.args` | Args override in diagnostic mode | `["infinity"]` |

### Container parameters

| Parameter | Description | Default |
|---|---|---|
| `command` | Override container command | `[]` |
| `args` | Override container args | `[]` |
| `resources` | Resource requests and limits | `{}` |
| `resourcesPreset` | Resource preset (nano/micro/small/medium/large/xlarge/2xlarge) | `""` |

### Probes

| Parameter | Description | Default |
|---|---|---|
| `livenessProbe.enabled` | Enable liveness probe | `true` |
| `readinessProbe.enabled` | Enable readiness probe | `true` |
| `startupProbe.enabled` | Enable startup probe | `true` |
| `customLivenessProbe` | Override liveness probe | `{}` |
| `customReadinessProbe` | Override readiness probe | `{}` |
| `customStartupProbe` | Override startup probe | `{}` |

### Pod parameters

| Parameter | Description | Default |
|---|---|---|
| `podLabels` | Additional pod labels | `{}` |
| `podAnnotations` | Additional pod annotations | `{}` |
| `podSecurityContext` | Pod security context | `{fsGroup: 999, seccompProfile: RuntimeDefault}` |
| `containerSecurityContext` | Container security context | `{runAsNonRoot: true, runAsUser: 999, readOnlyRootFilesystem: true, allowPrivilegeEscalation: false, capabilities.drop: [ALL]}` |
| `podAntiAffinityPreset` | Pod anti-affinity preset | `soft` |
| `terminationGracePeriodSeconds` | Termination grace period | `30` |

### Service parameters

| Parameter | Description | Default |
|---|---|---|
| `service.enabled` | Create a Service | `true` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Redis port | `6379` |
| `service.clusterPort` | Cluster bus port | `16379` |

### PodDisruptionBudget

| Parameter | Description | Default |
|---|---|---|
| `pdb.enabled` | Enable PDB | `false` |
| `pdb.minAvailable` | Minimum available pods | `""` |
| `pdb.maxUnavailable` | Maximum unavailable pods | `1` |

### Service account

| Parameter | Description | Default |
|---|---|---|
| `serviceAccount.create` | Create a ServiceAccount | `true` |
| `serviceAccount.name` | ServiceAccount name (generated if empty) | `""` |
| `serviceAccount.annotations` | ServiceAccount annotations | `{}` |
| `serviceAccount.automountServiceAccountToken` | Automount API credentials | `false` |

### RBAC

| Parameter | Description | Default |
|---|---|---|
| `rbac.create` | Create RBAC resources | `false` |
| `rbac.clusterRole.rules` | ClusterRole rules | `[]` |
| `rbac.role.rules` | Role rules | `[]` |

### Autoscaling (HPA)

| Parameter | Description | Default |
|---|---|---|
| `autoscaling.enabled` | Enable Horizontal Pod Autoscaler | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas | `3` |
| `autoscaling.maxReplicas` | Maximum number of replicas | `11` |
| `autoscaling.targetCPU` | Target CPU utilization percentage | `50` |
| `autoscaling.targetMemory` | Target memory utilization percentage | `""` |
| `autoscaling.customMetrics` | Custom metrics for autoscaling | `[]` |

### NetworkPolicy

| Parameter | Description | Default |
|---|---|---|
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |
| `networkPolicy.policyTypes` | Policy types | `[Ingress, Egress]` |
| `networkPolicy.ingress` | Extra ingress rules | `[]` |
| `networkPolicy.egress` | Extra egress rules | `[]` |
| `networkPolicy.allowExternalDNS` | Allow DNS egress | `true` |

### Metrics (redis-exporter)

| Parameter | Description | Default |
|---|---|---|
| `metrics.enabled` | Enable redis-exporter sidecar | `false` |
| `metrics.image.repository` | Exporter image | `oliver006/redis_exporter` |
| `metrics.image.tag` | Exporter tag | `v1.67.0` |
| `metrics.resources` | Exporter resources | `{}` |
| `serviceMonitor.enabled` | Enable ServiceMonitor | `false` |
| `prometheusRule.enabled` | Enable PrometheusRule | `false` |

### Persistence

| Parameter | Description | Default |
|---|---|---|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | PVC size | `8Gi` |
| `persistence.existingClaim` | Use existing PVC | `""` |
| `persistence.mountPath` | Data mount path | `/data` |

### PVC retention policy

| Parameter | Description | Default |
|---|---|---|
| `persistentVolumeClaimRetentionPolicy.enabled` | Enable PVC retention policy on StatefulSet | `false` |
| `persistentVolumeClaimRetentionPolicy.whenDeleted` | PVC retention when StatefulSet is deleted | `Retain` |
| `persistentVolumeClaimRetentionPolicy.whenScaled` | PVC retention when StatefulSet is scaled down | `Retain` |

### IP family

| Parameter | Description | Default |
|---|---|---|
| `ipFamily` | IP family for Redis announce address (`auto`, `ipv4`, `ipv6`) | `auto` |

### Init containers

| Parameter | Description | Default |
|---|---|---|
| `volumePermissions.enabled` | Run chown on data volume | `false` |
| `volumePermissions.image` | Volume permissions image | `alpine:latest` |
| `sysctl.enabled` | Tune kernel parameters | `false` |
| `sysctl.image` | Sysctl image | `alpine:latest` |

See `values.yaml` for the full list of parameters.
