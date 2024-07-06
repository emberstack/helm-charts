# Argo CD Helm Extensions
This chart provides templates for Argo CD CRDs. It can be used as the base for dynamic resources.
>Requirements: Argo CD installed in the cluster.

### Deployment to Kubernetes using Helm

Use Helm to install the latest released chart:
```shellsession
$ helm repo add emberstack https://emberstack.github.io/helm-charts
$ helm repo update
$ helm upgrade --install argo-cd-extensions emberstack/argo-cd-extensions
```

You can customize the values of the helm deployment by using the following Values:

| Parameter                | Description                        | Default                        |
| ------------------------ | ---------------------------------- | ------------------------------ |
| `applications`           | Array of ArgoCD Applications       | `[]`                           |
| `appProjects`            | Array of ArgoCD AppProject         | `[]`                           |
