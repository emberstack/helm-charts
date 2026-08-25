# NGINX Gateway Fabric Helm Extensions

This chart provides templates for NGINX Gateway Fabric CRDs. It can be used as the base for dynamic resources.

> Requirements: [NGINX Gateway Fabric](https://docs.nginx.com/nginx-gateway-fabric/) installed in the cluster.

Templates target the `gateway.nginx.org` group as shipped with **NGINX Gateway Fabric v2.6.7**.

| Kind | apiVersion | Values key |
|---|---|---|
| `ClientSettingsPolicy` | `v1alpha1` | `clientSettingsPolicies` |
| `ObservabilityPolicy` | `v1alpha2` | `observabilityPolicies` |
| `RateLimitPolicy` | `v1alpha1` | `rateLimitPolicies` |
| `UpstreamSettingsPolicy` | `v1alpha1` | `upstreamSettingsPolicies` |
| `ProxySettingsPolicy` | `v1alpha1` | `proxySettingsPolicies` |
| `SnippetsPolicy` | `v1alpha1` | `snippetsPolicies` |
| `SnippetsFilter` | `v1alpha1` | `snippetsFilters` |
| `NginxProxy` | `v1alpha2` | `nginxProxies` |
| `AuthenticationFilter` | `v1alpha1` | `authenticationFilters` |
| `WAFPolicy` | `v1alpha1` | `wafPolicies` |
| `NginxGateway` | `v1alpha1` | `nginxGateways` |

That is the complete `gateway.nginx.org` CRD set for v2.6.7. Every section is a **list**; each entry needs its
own `name` and is opt-in via `enabled: true`.

Notes:

- `WAFPolicy` requires NGINX Plus with App Protect WAF.
- `NginxGateway` is normally created by the NGINX Gateway Fabric chart itself — template it only if you manage
  that object yourself.
- `NginxProxy` is referenced from a `GatewayClass` or `Gateway` via `parametersRef`.
- `AuthenticationFilter` is referenced from an `HTTPRoute` filter via `extensionRef`.

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
| `clientSettingsPolicies` | List of ClientSettingsPolicies | `[]` |
| `observabilityPolicies` | List of ObservabilityPolicies | `[]` |
| `rateLimitPolicies` | List of RateLimitPolicies | `[]` |
| `upstreamSettingsPolicies` | List of UpstreamSettingsPolicies | `[]` |
| `proxySettingsPolicies` | List of ProxySettingsPolicies | `[]` |
| `snippetsPolicies` | List of SnippetsPolicies | `[]` |
| `snippetsFilters` | List of SnippetsFilters | `[]` |
| `nginxProxies` | List of NginxProxies | `[]` |
| `authenticationFilters` | List of AuthenticationFilters | `[]` |
| `wafPolicies` | List of WAFPolicies | `[]` |
| `nginxGateways` | List of NginxGateways | `[]` |

Per-entry keys: `name` (required), `enabled`, `fullnameOverride`, `namespace`, `labels`, `annotations`.

`targetRef` / `targetRefs` entries are always `{group, kind, name}` — all three required by the CRDs, with
sensible group/kind defaults supplied by the chart.

See [values.yaml](values.yaml) for the full annotated field reference.

## Upgrade note

A per-entry `namespace` is now honoured. Earlier versions accepted the key but silently ignored it, placing
every resource in the release namespace. If you had `namespace` set on an entry, the resource will move to
that namespace on upgrade — Helm deletes it from the old namespace and creates it in the new one. Remove the
key to keep the previous behaviour.

## Usage Examples

### ClientSettingsPolicy on a Gateway

```yaml
clientSettingsPolicies:
  - name: my-client-settings
    enabled: true
    targetRef:
      kind: Gateway
      name: my-gateway
    body:
      maxSize: 10m
      timeout: 60s
    keepAlive:
      requests: 100
      time: 1h
      timeout:
        server: 75s
        header: 60s
```

### ObservabilityPolicy with tracing

```yaml
observabilityPolicies:
  - name: my-observability
    enabled: true
    targetRefs:
      - kind: HTTPRoute
        name: my-route
    tracing:
      strategy: ratio
      ratio: 10
      context: extract
      spanAttributes:
        - key: env
          value: production
```

### RateLimitPolicy

`rateLimit.local.rules[].key` and `.rate` are both required.

```yaml
rateLimitPolicies:
  - name: my-rate-limit
    enabled: true
    targetRefs:
      - kind: HTTPRoute
        name: my-route
    rateLimit:
      logLevel: info
      rejectCode: 429
      local:
        rules:
          - key: $binary_remote_addr
            rate: 10r/s
            burst: 20
            zoneSize: 10m
```

### UpstreamSettingsPolicy on a Service

```yaml
upstreamSettingsPolicies:
  - name: my-upstream-settings
    enabled: true
    targetRefs:
      - kind: Service
        name: my-service
    zoneSize: 512k
    loadBalancingMethod: least_conn
    keepAlive:
      connections: 32
      requests: 100
      timeout: 60s
```

### ProxySettingsPolicy with buffering and timeouts

```yaml
proxySettingsPolicies:
  - name: my-proxy-settings
    enabled: true
    targetRefs:
      - kind: HTTPRoute
        name: my-route
    buffering:
      bufferSize: 4k
      buffers:
        number: 8
        size: 4k
      busyBuffersSize: 8k
    timeout:
      connect: 60s
      read: 60s
      send: 60s
```

### SnippetsPolicy and SnippetsFilter

```yaml
snippetsPolicies:
  - name: my-snippets-policy
    enabled: true
    targetRefs:
      - kind: HTTPRoute
        name: my-route
    snippets:
      - context: http.server.location
        value: "proxy_set_header X-Custom-Header value;"

snippetsFilters:
  - name: my-snippets-filter
    enabled: true
    snippets:
      - context: http.server.location
        value: "proxy_set_header X-Custom-Header value;"
```

### NginxProxy referenced from a GatewayClass

```yaml
nginxProxies:
  - name: my-proxy-config
    enabled: true
    fullnameOverride: nginx-proxy-config
    ipFamily: dual
    workerConnections: 1024
    disableHTTP2: false
    logging:
      errorLevel: info
```

Then point a `GatewayClass` at it:

```yaml
gatewayClasses:
  nginx:
    enabled: true
    controllerName: gateway.nginx.org/nginx-gateway-controller
    parametersRef:
      group: gateway.nginx.org
      kind: NginxProxy
      name: nginx-proxy-config
      namespace: default
```

(that second block belongs to the `gateway-api-extensions` chart)

### AuthenticationFilter with basic auth

```yaml
authenticationFilters:
  - name: my-auth
    enabled: true
    type: Basic
    basic:
      realm: Restricted
      secretRef:
        name: htpasswd-secret
```

### WAFPolicy (NGINX Plus with App Protect)

```yaml
wafPolicies:
  - name: my-waf
    enabled: true
    type: HTTP
    targetRefs:
      - kind: Gateway
        name: my-gateway
    policySource:
      httpSource:
        url: https://example.com/policies/waf-policy.tgz
      polling:
        enabled: true
        interval: 5m
```

### NginxGateway control-plane logging

```yaml
nginxGateways:
  - name: my-nginx-gateway
    enabled: true
    logging:
      level: debug
```
