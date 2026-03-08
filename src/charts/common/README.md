# common

A library Helm chart that provides common templates and helpers used by all EmberStack charts.

## Overview

This is a **library** chart — it cannot be installed directly. It provides reusable named templates for:

- **Names & labels** — fullname, namespace, standard Kubernetes labels, match labels
- **Images** — registry/repository/tag resolution with global overrides, pull secrets
- **Security** — pod and container security context rendering, OpenShift compatibility
- **Secrets** — secret lookup and generation helpers
- **Affinities** — pod affinity/anti-affinity presets, node affinity presets
- **Resources** — t-shirt size resource presets (nano, micro, small, medium, large, xlarge, 2xlarge)
- **Storage** — storage class resolution with global override
- **Ingress** — backend and TLS rendering for Ingress resources
- **Capabilities** — API version detection for different Kubernetes versions
- **Validation** — required value assertions
- **Template rendering** — render strings as templates (tplvalues)
- **Annotations** — annotation rendering helpers
- **Utilities** — getValueFromKey, getKeyFromList, checksumTemplate helpers
- **Item helpers** — enabled state resolution for list/map items

## Usage

Add as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: 1.x.x
    repository: oci://ghcr.io/emberstack/helm-charts
```

Then use the templates in your chart:

```yaml
metadata:
  name: {{ include "common.names.fullname" . }}
  labels:
    {{- include "common.labels.standard" (dict "customLabels" .Values.commonLabels "context" $) | nindent 4 }}
```

## Global Values

The library respects these global overrides:

| Parameter | Description |
|-----------|-------------|
| `global.image.registry` | Override image registry for all containers |
| `global.image.tag` | Override image tag for all containers |
| `global.image.pullSecrets` | Pull secrets for all containers |
| `global.storageClass` | Override storage class |
| `global.kubeVersion` | Override detected Kubernetes version |
| `global.compatibility.openshift.adaptSecurityContext` | OpenShift security context adaptation (`force`, `disabled`, `auto`) |
