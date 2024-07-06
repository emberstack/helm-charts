# cert-manager Helm Extensions
This chart provides templates for external-dns CRDs. It can be used as the base for dynamic resources.
> Requirements: external-dns installed in the cluster.

### Deployment to Kubernetes using Helm

Use Helm to install the latest released chart:
```shellsession
$ helm repo add emberstack https://emberstack.github.io/helm-charts
$ helm repo update
$ helm upgrade --install external-dns-extensions emberstack/external-dns-extensions
```

You can customize the values of the helm deployment by using the following Values:

| Parameter                            | Description                                       | Default               |
| ------------------------------------ | --------------------------------------------------| --------------------- |
| `dnsEndpoints`                       | Array of DNSEndpoints to template                 | `[]`                  |
