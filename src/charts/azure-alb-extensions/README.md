# Azure ALB Helm Extensions

This chart provides templates for Azure Application Gateway for Containers (ALB) CRDs. It can be used as the base for dynamic resources.

> Requirements: Azure ALB Controller installed in the cluster.

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
| `webApplicationFirewallPolicies` | Map of WebApplicationFirewallPolicies | `{}` |
| `healthCheckPolicies` | Map of HealthCheckPolicies | `{}` |
| `routePolicies` | Map of RoutePolicies | `{}` |
| `frontendTLSPolicies` | Map of FrontendTLSPolicies | `{}` |
| `backendTLSPolicies` | Map of BackendTLSPolicies | `{}` |
| `backendLoadBalancingPolicies` | Map of BackendLoadBalancingPolicies | `{}` |

## Usage Examples

### WAF Policy on a Gateway

```yaml
webApplicationFirewallPolicies:
  - name: my-waf
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
  - name: my-healthcheck
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
  - name: my-route-policy
    enabled: true
    targetRef:
      group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: my-route
    default:
      timeouts:
        routeTimeout: 60s
      sessionAffinity:
        enabled: true
        affinityType: Application
        cookieName: my-cookie
        cookieDuration: 3600
```

### Frontend TLS Policy

```yaml
frontendTLSPolicies:
  - name: my-frontend-tls
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
        name: "2024-01"
```

### Backend Load Balancing Policy

```yaml
backendLoadBalancingPolicies:
  - name: my-lb-policy
    enabled: true
    targetRefs:
      - group: ""
        kind: Service
        name: my-service
    loadBalancing:
      strategy: RoundRobin
```
