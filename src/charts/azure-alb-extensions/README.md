# Azure ALB Helm Extensions

This chart provides templates for Azure Application Gateway for Containers (ALB) CRDs. It can be used as the base for dynamic resources.

> Requirements: [ALB Controller](https://learn.microsoft.com/azure/application-gateway/for-containers/quickstart-deploy-application-gateway-for-containers-alb-controller) installed in the cluster.

Templates target the `alb.networking.azure.io/v1` API as shipped with **ALB Controller 1.11.4** (Gateway API v1.5.1).

| Kind | Values key | Notes |
|---|---|---|
| `ApplicationLoadBalancer` | `applicationLoadBalancers` | |
| `WebApplicationFirewallPolicy` | `webApplicationFirewallPolicies` | Requires `securityPolicyFeatureFlag` (default `true`) |
| `HealthCheckPolicy` | `healthCheckPolicies` | |
| `RoutePolicy` | `routePolicies` | |
| `FrontendTLSPolicy` | `frontendTLSPolicies` | |
| `BackendTLSPolicy` | `backendTLSPolicies` | |
| `BackendLoadBalancingPolicy` | `backendLoadBalancingPolicies` | |
| `IPAccessRulesPolicy` | `ipAccessRulesPolicies` | Requires `ipAccessRulesFeatureFlag=true` (default `false`) |
| `IngressExtension` | `ingressExtensions` | Ingress API only |

Every entry is a **map keyed by resource name** and is opt-in via `enabled: true`.

## Installation

### Using OCI registry (recommended)

```bash
helm install azure-alb-extensions oci://ghcr.io/emberstack/helm-charts/azure-alb-extensions
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install azure-alb-extensions emberstack/azure-alb-extensions
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `applicationLoadBalancers` | Map of ApplicationLoadBalancers | `{}` |
| `webApplicationFirewallPolicies` | Map of WebApplicationFirewallPolicies | `{}` |
| `healthCheckPolicies` | Map of HealthCheckPolicies | `{}` |
| `routePolicies` | Map of RoutePolicies | `{}` |
| `frontendTLSPolicies` | Map of FrontendTLSPolicies | `{}` |
| `backendTLSPolicies` | Map of BackendTLSPolicies | `{}` |
| `backendLoadBalancingPolicies` | Map of BackendLoadBalancingPolicies | `{}` |
| `ipAccessRulesPolicies` | Map of IPAccessRulesPolicies | `{}` |
| `ingressExtensions` | Map of IngressExtensions | `{}` |

Per-item keys common to every kind: `enabled`, `fullnameOverride`, `labels`, `annotations`.

Policy kinds (`healthCheckPolicies`, `routePolicies`, `frontendTLSPolicies`, `backendTLSPolicies`) accept both
`default` (applied unless the target specifies its own value) and `override` (always wins), matching the
Gateway API policy attachment model.

See [values.yaml](values.yaml) for the full annotated field reference.

## Usage Examples

### Application Load Balancer

```yaml
applicationLoadBalancers:
  my-alb:
    enabled: true
    associations:
      - /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>
```

### WAF Policy on a Gateway

```yaml
webApplicationFirewallPolicies:
  my-waf:
    enabled: true
    targetRef:
      group: gateway.networking.k8s.io
      kind: Gateway
      name: my-gateway
    webApplicationFirewall:
      id: /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/<policy>
```

### Health Check Policy on a Service

```yaml
healthCheckPolicies:
  my-healthcheck:
    enabled: true
    targetRef:
      group: ""
      kind: Service
      name: my-service
    default:
      port: 8080
      interval: 5s
      timeout: 5s
      healthyThreshold: 3
      unhealthyThreshold: 3
      http:
        host: my-service.example.com
        path: /health
        match:
          statusCodes:
            - start: 200
              end: 299
```

### Route Policy with session affinity and timeouts

```yaml
routePolicies:
  my-route-policy:
    enabled: true
    targetRef:
      group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: my-route
    default:
      timeouts:
        routeTimeout: 60s
      sessionAffinity:
        affinityType: application-cookie
        cookieName: my-cookie
        cookieDuration: 3600s
```

### Frontend TLS Policy

```yaml
frontendTLSPolicies:
  my-frontend-tls:
    enabled: true
    targetRef:
      group: gateway.networking.k8s.io
      kind: Gateway
      name: my-gateway
      sectionNames:
        - https
    default:
      policyType:
        type: predefined
        name: "2023-06"
```

### Backend Load Balancing Policy

```yaml
backendLoadBalancingPolicies:
  my-lb-policy:
    enabled: true
    targetRefs:
      - targetRef:
          group: ""
          kind: Service
          name: my-service
        ports:
          - port: 8080
    loadBalancing:
      strategy: round-robin
```

### IP Access Rules Policy

```yaml
ipAccessRulesPolicies:
  my-ip-rules:
    enabled: true
    targetRefs:
      - group: gateway.networking.k8s.io
        kind: Gateway
        name: my-gateway
    ipAccessRules:
      - name: allow-corp
        action: Allow
        priority: 100
        sourceAddressPrefixes:
          - 10.0.0.0/8
```

### Ingress Extension

```yaml
ingressExtensions:
  my-ingress-extension:
    enabled: true
    backendSettings:
      - service: my-service
        ports:
          - port: 8080
            protocol: HTTP
        timeouts:
          requestTimeout: 60s
    rules:
      - host: www.example.com
        requestRedirect:
          scheme: https
          statusCode: 301
```

## Upgrade notes

### `backendLoadBalancingPolicies[].targetRefs`

The `BackendLoadBalancingPolicy` CRD nests each reference under `targetRef` and allows per-reference `ports`.
Earlier chart versions emitted a flat list, which the API server rejects. Update your values:

```yaml
# before (rejected by the API server)
targetRefs:
  - group: ""
    kind: Service
    name: my-service

# after
targetRefs:
  - targetRef:
      group: ""
      kind: Service
      name: my-service
```

The chart fails rendering with an explicit message if the old shape is detected.

### `routePolicies[].default.sessionAffinity`

`affinityType` must be `application-cookie` or `managed-cookie`. There is no `enabled` field; omit
`sessionAffinity` entirely to disable it.
