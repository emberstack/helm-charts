# Gateway API Helm Extensions

This chart provides templates for Gateway API resources. It can be used as the base for dynamic resources.

> Requirements: Gateway API CRDs installed in the cluster (e.g. via the upstream `gateway-api` manifests or your cloud provider).

Templates target the **Gateway API standard channel, v1.6.1**.

| Kind | apiVersion | Values key | Minimum Gateway API |
|---|---|---|---|
| `GatewayClass` (cluster-scoped) | `gateway.networking.k8s.io/v1` | `gatewayClasses` | v1.0 |
| `Gateway` | `gateway.networking.k8s.io/v1` | `gateways` | v1.0 |
| `ListenerSet` | `gateway.networking.k8s.io/v1` | `listenerSets` | v1.5 |
| `HTTPRoute` | `gateway.networking.k8s.io/v1` | `httpRoutes` | v1.0 |
| `GRPCRoute` | `gateway.networking.k8s.io/v1` | `grpcRoutes` | v1.1 |
| `TLSRoute` | `gateway.networking.k8s.io/v1` | `tlsRoutes` | v1.5 |
| `TCPRoute` | `gateway.networking.k8s.io/v1` | `tcpRoutes` | **v1.6** |
| `UDPRoute` | `gateway.networking.k8s.io/v1` | `udpRoutes` | **v1.6** |
| `BackendTLSPolicy` | `gateway.networking.k8s.io/v1` | `backendTLSPolicies` | v1.4 |
| `ReferenceGrant` | `gateway.networking.k8s.io/v1beta1` | `referenceGrants` | v1.0 |

Every entry is a **map keyed by resource name** and is opt-in via `enabled: true`.

Notes:

- `ReferenceGrant` is emitted as `v1beta1`, which is still the storage version upstream in v1.6.1 and is served by every
  supported release. This keeps the chart compatible with older clusters; `v1` is served but not yet the storage version.
- `TCPRoute` and `UDPRoute` only graduated to the standard channel in Gateway API v1.6. On older clusters they exist only
  in the experimental channel, so these sections render resources your API server may not recognise.
- Experimental `gateway.networking.x-k8s.io` resources (`XBackend`, `XBackendTrafficPolicy`, `XMesh`) are intentionally
  out of scope for this chart.

## Installation

### Using OCI registry (recommended)

```bash
helm install gateway-api-extensions oci://ghcr.io/emberstack/helm-charts/gateway-api-extensions
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install gateway-api-extensions emberstack/gateway-api-extensions
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `gatewayClasses` | Map of GatewayClasses | `{}` |
| `gateways` | Map of Gateways | `{}` |
| `listenerSets` | Map of ListenerSets | `{}` |
| `httpRoutes` | Map of HTTPRoutes | `{}` |
| `grpcRoutes` | Map of GRPCRoutes | `{}` |
| `tlsRoutes` | Map of TLSRoutes | `{}` |
| `tcpRoutes` | Map of TCPRoutes | `{}` |
| `udpRoutes` | Map of UDPRoutes | `{}` |
| `backendTLSPolicies` | Map of BackendTLSPolicies | `{}` |
| `referenceGrants` | Map of ReferenceGrants | `{}` |

Per-item keys common to every kind: `enabled`, `fullnameOverride`, `labels`, `annotations`.

See [values.yaml](values.yaml) for the full annotated field reference.

## Usage Examples

### GatewayClass

```yaml
gatewayClasses:
  nginx:
    enabled: true
    controllerName: gateway.nginx.org/nginx-gateway-controller
    description: NGINX Gateway Fabric
```

### Gateway with HTTP and HTTPS listeners

```yaml
gateways:
  main:
    enabled: true
    gatewayClassName: nginx
    listeners:
      - name: http
        port: 80
        protocol: HTTP
        hostname: "*.example.com"
        allowedRoutes:
          namespaces:
            from: All
      - name: https
        port: 443
        protocol: HTTPS
        hostname: "*.example.com"
        tls:
          mode: Terminate
          certificateRefs:
            - name: wildcard-tls
              namespace: cert-manager
        allowedRoutes:
          namespaces:
            from: All
```

### Gateway accepting ListenerSets

```yaml
gateways:
  main:
    enabled: true
    gatewayClassName: nginx
    listeners:
      - name: https
        port: 443
        protocol: HTTPS
    allowedListeners:
      namespaces:
        from: Same
```

### ListenerSet attaching extra listeners

```yaml
listenerSets:
  extra:
    enabled: true
    parentRef:
      name: main
    listeners:
      - name: extra-https
        port: 8443
        protocol: HTTPS
        tls:
          mode: Terminate
          certificateRefs:
            - name: extra-tls
```

### HTTPRoute with path-based routing

```yaml
httpRoutes:
  my-app:
    enabled: true
    parentRefs:
      - name: main
        sectionName: https
    hostnames:
      - app.example.com
    rules:
      - matches:
          - path:
              type: PathPrefix
              value: /api
        backendRefs:
          - name: api-service
            port: 8080
      - matches:
          - path:
              type: PathPrefix
              value: /
        backendRefs:
          - name: frontend-service
            port: 3000
```

### HTTPRoute with HTTP-to-HTTPS redirect

```yaml
httpRoutes:
  redirect-http:
    enabled: true
    parentRefs:
      - name: main
        sectionName: http
    hostnames:
      - app.example.com
    rules:
      - filters:
          - type: RequestRedirect
            requestRedirect:
              scheme: https
              statusCode: 301
```

### GRPCRoute

```yaml
grpcRoutes:
  my-grpc:
    enabled: true
    parentRefs:
      - name: main
        sectionName: https
    hostnames:
      - grpc.example.com
    rules:
      - matches:
          - method:
              service: my.package.Service
              method: MyMethod
        backendRefs:
          - name: grpc-service
            port: 9090
```

### TLSRoute (passthrough)

```yaml
tlsRoutes:
  passthrough:
    enabled: true
    parentRefs:
      - name: main
        sectionName: tls
    hostnames:
      - secure.example.com
    rules:
      - backendRefs:
          - name: tls-backend
            port: 8443
```

### TCPRoute and UDPRoute

```yaml
tcpRoutes:
  postgres:
    enabled: true
    parentRefs:
      - name: main
        sectionName: postgres
    rules:
      - backendRefs:
          - name: postgres
            port: 5432

udpRoutes:
  dns:
    enabled: true
    parentRefs:
      - name: main
        sectionName: dns
    rules:
      - backendRefs:
          - name: coredns
            port: 53
```

### BackendTLSPolicy

```yaml
backendTLSPolicies:
  my-backend:
    enabled: true
    targetRefs:
      - group: ""
        kind: Service
        name: my-service
    validation:
      hostname: backend.example.com
      caCertificateRefs:
        - name: ca-bundle
          kind: ConfigMap
          group: ""
```

### ReferenceGrant for cross-namespace certificate

```yaml
referenceGrants:
  allow-cert-ref:
    enabled: true
    from:
      - group: gateway.networking.k8s.io
        kind: Gateway
        namespace: default
    to:
      - group: ""
        kind: Secret
        name: wildcard-tls
```
