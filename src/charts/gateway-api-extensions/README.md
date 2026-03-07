# Gateway API Helm Extensions

This chart provides templates for Gateway API resources (Gateways, HTTPRoutes, ReferenceGrants). It can be used as the base for dynamic resources.

> Requirements: Gateway API CRDs installed in the cluster (e.g. via `gateway-api` chart or cloud provider).

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
| `gateways` | Array of Gateways | `[]` |
| `httpRoutes` | Array of HTTPRoutes | `[]` |
| `referenceGrants` | Array of ReferenceGrants | `[]` |

## Usage Examples

### Gateway with HTTP and HTTPS listeners

```yaml
gateways:
  - name: main
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

### HTTPRoute with path-based routing

```yaml
httpRoutes:
  - name: my-app
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
  - name: redirect-http
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

### ReferenceGrant for cross-namespace certificate

```yaml
referenceGrants:
  - name: allow-cert-ref
    from:
      - group: gateway.networking.k8s.io
        kind: Gateway
        namespace: default
    to:
      - group: ""
        kind: Secret
        name: wildcard-tls
```
