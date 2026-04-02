# Generic Helm Chart

A generic application Helm chart for deploying any containerized workload on Kubernetes. Supports Deployment and CronJob modes, Gateway API HTTPRoute, Ingress, RBAC, autoscaling, and more.

## Installation

### Using OCI registry (recommended)

```bash
helm install my-release oci://ghcr.io/emberstack/helm-charts/generic \
  --set image.repository=nginx \
  --set image.tag=latest
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install my-release emberstack/generic \
  --set image.repository=nginx \
  --set image.tag=latest
```

### As a subchart dependency

```yaml
# Chart.yaml
dependencies:
  - name: generic
    version: "1.x.x"
    repository: "oci://ghcr.io/emberstack/helm-charts"
    alias: api
    condition: api.enabled
```

```yaml
# values.yaml
api:
  enabled: true
  image:
    repository: my-registry/my-app
  httpRoute:
    enabled: true
    parentRefs:
      - name: my-gateway
        sectionName: https
    hostnames:
      - my-app.example.com
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
| `image.registry` | Image registry | `""` |
| `image.repository` | Image repository | `""` |
| `image.tag` | Image tag (defaults to `Chart.AppVersion`) | `""` |
| `image.digest` | Image digest (overrides tag) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Image pull secrets | `[]` |

## Test Image Parameters

| Parameter | Description | Default |
|---|---|---|
| `testImage.registry` | Test image registry | `docker.io` |
| `testImage.repository` | Test image repository | `busybox` |
| `testImage.tag` | Test image tag | `latest` |
| `testImage.pullPolicy` | Test image pull policy | `IfNotPresent` |

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

## CronJob Parameters

Mutually exclusive with Deployment — set `deployment.enabled: false` when using CronJob mode.

| Parameter | Description | Default |
|---|---|---|
| `cronJob.enabled` | Deploy as CronJob | `false` |
| `cronJob.schedule` | Cron schedule expression (required) | `""` |
| `cronJob.concurrencyPolicy` | Concurrency policy | `Forbid` |
| `cronJob.failedJobsHistoryLimit` | Failed jobs history limit | `1` |
| `cronJob.successfulJobsHistoryLimit` | Successful jobs history limit | `3` |
| `cronJob.startingDeadlineSeconds` | Starting deadline | `""` |
| `cronJob.suspend` | Suspend the CronJob | `false` |
| `cronJob.backoffLimit` | Job backoff limit | `6` |
| `cronJob.activeDeadlineSeconds` | Active deadline for jobs | `""` |
| `cronJob.ttlSecondsAfterFinished` | TTL for finished jobs | `""` |
| `cronJob.restartPolicy` | Pod restart policy | `OnFailure` |
| `cronJob.annotations` | CronJob annotations | `{}` |
| `cronJob.labels` | CronJob labels | `{}` |

## Container Parameters

| Parameter | Description | Default |
|---|---|---|
| `command` | Override container command | `[]` |
| `args` | Override container args | `[]` |
| `containerPort` | Primary container port | `8080` |
| `extraContainerPorts` | Additional container ports | `[]` |
| `resources` | Resource requests and limits | `{}` |
| `resourcesPreset` | Resource preset (nano/micro/small/medium/large/xlarge/2xlarge) | `""` |
| `lifecycleHooks` | Lifecycle hooks | `{}` |
| `extraEnvVars` | Additional environment variables | `[]` |
| `extraEnvVarsCM` | ConfigMap name for envFrom | `""` |
| `extraEnvVarsSecret` | Secret name for envFrom | `""` |
| `extraVolumeMounts` | Additional volume mounts | `[]` |
| `extraVolumes` | Additional volumes | `[]` |

## Diagnostic Mode

Overrides command, args, and disables probes and lifecycle hooks for debugging.

| Parameter | Description | Default |
|---|---|---|
| `diagnosticMode.enabled` | Enable diagnostic mode | `false` |
| `diagnosticMode.command` | Diagnostic command | `["sleep"]` |
| `diagnosticMode.args` | Diagnostic args | `["infinity"]` |

## Probes

Default probes can be overridden with `custom*Probe` or disabled entirely with `diagnosticMode`.

| Parameter | Description | Default |
|---|---|---|
| `livenessProbe` | Default liveness probe | httpGet `/healthz` |
| `customLivenessProbe` | Override liveness probe | `{}` |
| `readinessProbe` | Default readiness probe | httpGet `/healthz` |
| `customReadinessProbe` | Override readiness probe | `{}` |
| `startupProbe` | Default startup probe | httpGet `/healthz` |
| `customStartupProbe` | Override startup probe | `{}` |

## Pod Parameters

| Parameter | Description | Default |
|---|---|---|
| `podLabels` | Additional pod labels | `{}` |
| `podAnnotations` | Additional pod annotations | `{}` |
| `podSecurityContext` | Pod security context | `{enabled: true, fsGroup: 1001, ...}` |
| `containerSecurityContext` | Container security context | `{enabled: true, runAsNonRoot: true, ...}` |
| `podAffinityPreset` | Pod affinity preset (soft/hard) | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset (soft/hard) | `soft` |
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
| `extraContainers` | Extra containers | `[]` |

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
| `service.port` | Service port | `80` |
| `service.targetPort` | Target port | `http` |
| `service.nodePort` | NodePort (when type=NodePort) | `""` |
| `service.clusterIP` | Cluster IP (use `None` for headless) | `""` |
| `service.loadBalancerIP` | Load balancer IP | `""` |
| `service.loadBalancerSourceRanges` | Load balancer source ranges | `[]` |
| `service.externalTrafficPolicy` | External traffic policy | `""` |
| `service.internalTrafficPolicy` | Internal traffic policy | `""` |
| `service.sessionAffinity` | Session affinity (None/ClientIP) | `""` |
| `service.sessionAffinityConfig` | Session affinity config | `{}` |
| `service.annotations` | Service annotations | `{}` |
| `service.labels` | Service labels | `{}` |
| `service.extraPorts` | Additional service ports | `[]` |

## Ingress

| Parameter | Description | Default |
|---|---|---|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.ingressClassName` | Ingress class name | `""` |
| `ingress.hostname` | Ingress hostname | `""` |
| `ingress.path` | Ingress path | `/` |
| `ingress.pathType` | Path type | `Prefix` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.labels` | Ingress labels | `{}` |
| `ingress.tls` | Enable TLS | `false` |
| `ingress.extraHosts` | Additional hosts | `[]` |
| `ingress.extraTls` | Additional TLS entries | `[]` |
| `ingress.extraRules` | Additional rules | `[]` |

## HTTPRoute (Gateway API)

| Parameter | Description | Default |
|---|---|---|
| `httpRoute.enabled` | Enable HTTPRoute | `false` |
| `httpRoute.parentRefs` | Gateway parent references | `[]` |
| `httpRoute.hostnames` | Route hostnames | `[]` |
| `httpRoute.rules` | Route rules (auto-generates default if empty) | `[]` |
| `httpRoute.annotations` | HTTPRoute annotations | `{}` |
| `httpRoute.labels` | HTTPRoute labels | `{}` |
| `httpRoute.httpRedirect.enabled` | Enable HTTP→HTTPS redirect companion | `false` |
| `httpRoute.httpRedirect.parentRefs` | Redirect parent refs (defaults to main) | `[]` |
| `httpRoute.httpRedirect.hostnames` | Redirect hostnames (defaults to main) | `[]` |
| `httpRoute.httpRedirect.annotations` | Redirect annotations (defaults to main) | `{}` |
| `httpRoute.httpRedirect.labels` | Redirect labels (defaults to main) | `{}` |
| `httpRoute.httpRedirect.scheme` | Redirect scheme | `https` |
| `httpRoute.httpRedirect.statusCode` | Redirect status code | `301` |
| `httpRoute.httpRedirect.port` | Redirect port | `""` |
| `httpRoute.httpRedirect.path` | Redirect path | `{}` |

## Autoscaling (HPA)

| Parameter | Description | Default |
|---|---|---|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `autoscaling.targetCPU` | Target CPU utilization | `80` |
| `autoscaling.targetMemory` | Target memory utilization | `""` |
| `autoscaling.behavior` | Scaling behavior | `{}` |
| `autoscaling.customMetrics` | Custom metrics | `[]` |

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
| `serviceMonitor.port` | Metrics port | `http` |
| `serviceMonitor.path` | Metrics path | `/metrics` |
| `serviceMonitor.interval` | Scrape interval | `30s` |
| `serviceMonitor.scrapeTimeout` | Scrape timeout | `""` |
| `serviceMonitor.labels` | Additional labels | `{}` |
| `serviceMonitor.annotations` | Additional annotations | `{}` |
| `serviceMonitor.relabelings` | Relabeling rules | `[]` |
| `serviceMonitor.metricRelabelings` | Metric relabeling rules | `[]` |
| `serviceMonitor.honorLabels` | Honor labels | `false` |

## PodMonitor (Prometheus)

| Parameter | Description | Default |
|---|---|---|
| `podMonitor.enabled` | Enable PodMonitor | `false` |
| `podMonitor.namespace` | PodMonitor namespace | `""` |
| `podMonitor.podMetricsEndpoints` | Pod metrics endpoints | `[{port: http, path: /metrics}]` |
| `podMonitor.interval` | Scrape interval | `30s` |
| `podMonitor.scrapeTimeout` | Scrape timeout | `""` |
| `podMonitor.labels` | Additional labels | `{}` |
| `podMonitor.annotations` | Additional annotations | `{}` |
| `podMonitor.relabelings` | Relabeling rules | `[]` |
| `podMonitor.metricRelabelings` | Metric relabeling rules | `[]` |
| `podMonitor.honorLabels` | Honor labels | `false` |

## ConfigMap

| Parameter | Description | Default |
|---|---|---|
| `configMap.enabled` | Create a ConfigMap | `false` |
| `configMap.data` | ConfigMap data (supports template expressions) | `{}` |

## Secret

| Parameter | Description | Default |
|---|---|---|
| `secret.enabled` | Create a Secret | `false` |
| `secret.type` | Secret type | `Opaque` |
| `secret.data` | Secret data (base64-encoded) | `{}` |
| `secret.stringData` | Secret string data (plain text) | `{}` |

## Persistence

| Parameter | Description | Default |
|---|---|---|
| `persistence.enabled` | Enable persistence | `false` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessModes` | Access modes | `[ReadWriteOnce]` |
| `persistence.size` | PVC size | `1Gi` |
| `persistence.existingClaim` | Use existing PVC | `""` |
| `persistence.mountPath` | Mount path | `/data` |
| `persistence.subPath` | Volume sub-path | `""` |
| `persistence.annotations` | PVC annotations | `{}` |
