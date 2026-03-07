# NGINX Gateway Fabric Helm Extensions

This chart provides templates for NGINX Gateway Fabric CRDs. It can be used as the base for dynamic resources.

> Requirements: NGINX Gateway Fabric installed in the cluster.

## Installation

### Using OCI registry (recommended)

```bash
helm install nginx-gateway-fabric-extensions oci://ghcr.io/emberstack/helm-charts/nginx-gateway-fabric-extensions
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install nginx-gateway-fabric-extensions emberstack/nginx-gateway-fabric-extensions
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `clientSettingsPolicies` | Array of ClientSettingsPolicies | `[]` |
| `observabilityPolicies` | Array of ObservabilityPolicies | `[]` |
| `rateLimitPolicies` | Array of RateLimitPolicies | `[]` |
| `upstreamSettingsPolicies` | Array of UpstreamSettingsPolicies | `[]` |
| `proxySettingsPolicies` | Array of ProxySettingsPolicies | `[]` |
| `snippetsPolicies` | Array of SnippetsPolicies | `[]` |
| `snippetsFilters` | Array of SnippetsFilters | `[]` |

## Usage Examples

### Client Settings Policy

```yaml
clientSettingsPolicies:
  - name: large-uploads
    enabled: true
    targetRef:
      group: gateway.networking.k8s.io
      kind: Gateway
      name: my-gateway
    body:
      maxSize: 50m
      timeout: 120s
    keepAlive:
      requests: 100
      time: 1h
      timeout:
        server: 75s
        header: 60s
```

### Rate Limit Policy

```yaml
rateLimitPolicies:
  - name: api-rate-limit
    enabled: true
    targetRefs:
      - group: gateway.networking.k8s.io
        kind: HTTPRoute
        name: api-route
    rateLimit:
      logLevel: info
      rejectCode: 429
      local:
        rules:
          - rate: 10r/s
            burst: 20
            delay: 5
            zoneSize: 10m
```

### Upstream Settings Policy

```yaml
upstreamSettingsPolicies:
  - name: my-upstream
    enabled: true
    targetRefs:
      - group: ""
        kind: Service
        name: my-service
    zoneSize: 512k
    loadBalancingMethod: least_conn
    keepAlive:
      connections: 32
      requests: 100
      time: 1h
      timeout: 60s
```

### Observability Policy

```yaml
observabilityPolicies:
  - name: tracing
    enabled: true
    targetRefs:
      - group: gateway.networking.k8s.io
        kind: HTTPRoute
        name: my-route
    tracing:
      strategy: ratio
      ratio: 10
      context: extract
      spanName: my-span
      spanAttributes:
        - key: env
          value: production
```
