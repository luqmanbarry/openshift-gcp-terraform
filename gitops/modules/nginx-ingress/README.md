# NGINX Ingress Controller

This helm chart deploys the nginx ingress controller operator and configures one or more `NginxIngress` CRs per namespace.

## Inputs

Required inputs are defined in the [values.yaml](./values.yaml) file of the helm chart. 

The recommended pattern is to keep all common (defaults) parameters set in the `values.yaml` and overwrite params that change per cluster in the `values.cluster-name.yaml` file.

## Dependencies

- Up & Running ARO cluster
- [External Secrets Operator](../external-secrets-operator/)
- NGINX Ingress TLS certificates stored in Azure Key Vault