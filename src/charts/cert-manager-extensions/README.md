# cert-manager Helm Extensions
This chart provides templates for cert-manager CRDs. It can be used as the base for dynamic resources.
> Requirements: cert-manager installed in the cluster.

### Deployment to Kubernetes using Helm

Use Helm to install the latest released chart:
```shellsession
$ helm repo add emberstack https://emberstack.github.io/helm-charts
$ helm repo update
$ helm upgrade --install cert-manager-extensions emberstack/cert-manager-extensions
```

You can customize the values of the helm deployment by using the following Values:

| Parameter                            | Description                                       | Default               |
| ------------------------------------ | --------------------------------------------------| --------------------- |
| `clusterIssuers`                     | Array of ClusterIssuers to template               | `[]`                  |
| `issuer`                             | Array of Issuers to template                      | `[]`                  |
| `certificates`                       | Array of Certificates to template                 | `[]`                  |
