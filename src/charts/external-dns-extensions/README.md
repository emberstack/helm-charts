# external-dns Helm Extensions

This chart provides templates for external-dns CRDs. It can be used as the base for dynamic resources.

> Requirements: [external-dns](https://kubernetes-sigs.github.io/external-dns/) installed in the cluster, with
> its CRD source enabled (`--source=crd`).

Templates target `externaldns.k8s.io/v1alpha1` as shipped with **external-dns v0.22.0**.

| Kind | Values key | Shape | Minimum external-dns |
|---|---|---|---|
| `DNSEndpoint` | `dnsEndpoints` | one resource, many endpoints | v0.5 |
| `DNSRecord` | `dnsRecords` | one resource per record | **v0.22.0** |

Both sections are **lists**; each entry needs its own `name` and is opt-in via `enabled: true`.

`DNSRecord` is new in external-dns v0.22.0 — the CRD does not exist in earlier releases, so that section
renders resources an older cluster will not recognise. `DNSEndpoint`'s schema is unchanged between v0.21 and v0.22.

Every endpoint requires `dnsName`, `recordType` and `targets`. Validation reports the exact path
(e.g. `dnsEndpoints[0].endpoints[2]: targets is required`).

## Installation

### Using OCI registry (recommended)

```bash
helm install external-dns-extensions oci://ghcr.io/emberstack/helm-charts/external-dns-extensions
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install external-dns-extensions emberstack/external-dns-extensions
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `dnsEndpoints` | List of DNSEndpoints | `[]` |
| `dnsRecords` | List of DNSRecords | `[]` |

Per-entry keys: `name` (required), `enabled`, `fullnameOverride`, `namespace`, `labels`, `annotations`.

Endpoint fields: `dnsName`, `recordType`, `targets` (all required), plus `recordTTL`, `setIdentifier`,
`labels` and `providerSpecific`.

See [values.yaml](values.yaml) for the full annotated reference.

## Usage Examples

### DNSEndpoint with A and CNAME records

```yaml
dnsEndpoints:
  - name: app-records
    enabled: true
    endpoints:
      - dnsName: app.example.com
        recordType: A
        recordTTL: 300
        targets:
          - 203.0.113.10
          - 203.0.113.11
      - dnsName: www.example.com
        recordType: CNAME
        recordTTL: 300
        targets:
          - app.example.com
```

### Weighted records with setIdentifier

```yaml
dnsEndpoints:
  - name: weighted
    enabled: true
    endpoints:
      - dnsName: api.example.com
        recordType: A
        setIdentifier: blue
        targets: [203.0.113.10]
        providerSpecific:
          - name: aws/weight
            value: "80"
      - dnsName: api.example.com
        recordType: A
        setIdentifier: green
        targets: [203.0.113.20]
        providerSpecific:
          - name: aws/weight
            value: "20"
```

### Provider-specific options

```yaml
dnsEndpoints:
  - name: proxied
    enabled: true
    endpoints:
      - dnsName: cdn.example.com
        recordType: A
        targets: [203.0.113.30]
        providerSpecific:
          - name: external-dns.alpha.kubernetes.io/cloudflare-proxied
            value: "true"
```

### DNSRecord (external-dns >= v0.22.0)

```yaml
dnsRecords:
  - name: app-a-record
    enabled: true
    endpoint:
      dnsName: app.example.com
      recordType: A
      recordTTL: 300
      targets:
        - 203.0.113.10
```

### Templated targets

```yaml
dnsEndpoints:
  - name: templated
    enabled: true
    endpoints:
      - dnsName: "{{ .Release.Name }}.example.com"
        recordType: CNAME
        targets:
          - "ingress.{{ .Release.Namespace }}.example.com"
```
