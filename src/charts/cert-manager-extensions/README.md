# cert-manager Helm Extensions

This chart provides templates for cert-manager CRDs. It can be used as the base for dynamic resources.

> Requirements: [cert-manager](https://cert-manager.io/docs/installation/) installed in the cluster.

Templates target the `cert-manager.io/v1` API as shipped with **cert-manager v1.21.1**.

| Kind | Values key | Shape |
|---|---|---|
| `Issuer` | `issuers` | **list** — each entry needs its own `name` |
| `ClusterIssuer` | `clusterIssuers` | **list** — each entry needs its own `name` |
| `Certificate` | `certificates` | **map** keyed by name |

Every entry is opt-in via `enabled: true`.

`CertificateRequest`, `Order` and `Challenge` are deliberately not templated — cert-manager's controllers
create and own those; they are not resources you author.

> Note the shape difference: `issuers` / `clusterIssuers` are lists (so `name` is required on each entry),
> while `certificates` is a map keyed by name (the key *is* the name — a per-item `name` is ignored there).

## Installation

### Using OCI registry (recommended)

```bash
helm install cert-manager-extensions oci://ghcr.io/emberstack/helm-charts/cert-manager-extensions
```

### Using Helm repository

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install cert-manager-extensions emberstack/cert-manager-extensions
```

## Parameters

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override chart name | `""` |
| `fullnameOverride` | Override fully qualified app name | `""` |
| `namespaceOverride` | Override namespace | `""` |
| `commonLabels` | Labels added to all resources | `{}` |
| `commonAnnotations` | Annotations added to all resources | `{}` |
| `issuers` | List of Issuers | `[]` |
| `clusterIssuers` | List of ClusterIssuers | `[]` |
| `certificates` | Map of Certificates (keyed by name) | `{}` |

Every field of the cert-manager v1.21.1 `IssuerSpec` and `CertificateSpec` is renderable.
See [values.yaml](values.yaml) for the full annotated reference.

## Usage Examples

### ACME ClusterIssuer with a DNS-01 solver

```yaml
clusterIssuers:
  - name: letsencrypt
    enabled: true
    acme:
      email: ops@example.com
      server: https://acme-v02.api.letsencrypt.org/directory
      privateKeySecretRef:
        name: letsencrypt-key
      solvers:
        - dns01:
            cloudflare:
              apiTokenSecretRef:
                name: cloudflare-token
                key: token
```

### CA and self-signed ClusterIssuers

```yaml
clusterIssuers:
  - name: internal-ca
    enabled: true
    ca:
      secretName: ca-key-pair
  - name: selfsigned
    enabled: true
    selfSigned: {}
```

### Vault Issuer with AWS IAM auth (cert-manager >= 1.21)

```yaml
issuers:
  - name: vault
    enabled: true
    vault:
      server: https://vault.example.com
      path: pki/sign/example
      auth:
        aws:
          role: vault-role
          region: eu-west-1
          serviceAccountRef:
            name: cert-manager
```

### Venafi Issuer using Next-Gen Trust Services (cert-manager >= 1.21)

```yaml
issuers:
  - name: venafi-ngts
    enabled: true
    venafi:
      zone: My Zone
      ngts:
        tsgID: my-tsg-id
        credentialsRef:
          name: ngts-credentials
```

### Certificate with renewal windows (cert-manager >= 1.21)

```yaml
certificates:
  web:
    enabled: true
    secretName: web-tls
    issuerRef:
      name: letsencrypt
      kind: ClusterIssuer
    dnsNames:
      - www.example.com
    duration: 2160h
    renewBefore: 360h
    renewal:
      policy: RenewBefore
      windows:
        - cron: "0 2 * * SAT"
          windowDuration: 4h
          timezone: UTC
```

### Certificate with a PKCS#12 keystore

```yaml
certificates:
  app:
    enabled: true
    secretName: app-tls
    issuerRef:
      name: internal-ca
      kind: ClusterIssuer
    dnsNames:
      - app.svc.cluster.local
    privateKey:
      algorithm: ECDSA
      size: 256
      rotationPolicy: Always
    keystores:
      pkcs12:
        create: true
        passwordSecretRef:
          name: p12-password
          key: password
```

### Per-environment DNS name additions

`certificates` is a map, so value files merge. `extraDnsNames` is appended to `dnsNames`,
letting an environment add hostnames without restating the certificate:

```yaml
certificates:
  web:
    extraDnsNames:
      - staging.example.com
```
