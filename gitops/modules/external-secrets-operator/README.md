# External Secrets Operator

This helm chart deploys the External Secrets Operator which is used to fetch sensitive data (secrets, certs) from Azure KeyVault. The docs are available [here](https://external-secrets.io/latest/provider/azure-key-vault/).

## Inputs

Required inputs are defined in the [values.yaml](./values.yaml) file of the helm chart. 

The recommended pattern is to keep all common (defaults) parameters set in the `values.yaml` and overwrite params that change per cluster in the `values.cluster-name.yaml` file.

## Dependencies

- Up & Running ARO cluster
- Azure Service Principal with read access to KeyVault

## Uninstall

1. Go to the Operator > Actions > Uninstall Operator or Delete ClusterServiceVersion
2. Go to Home > Search > Resources > Select All Projects and search for these resources and delete them.
   - ClusterExternalSecrets
   - ExternalSecrets
   - ClusterSecretStores
   - SecretStores
   - customresourcedefinition/clusterexternalsecrets.external-secrets.io
   - customresourcedefinition/clustersecretstores.external-secrets.io
   - customresourcedefinition/externalsecrets.external-secrets.io
   - customresourcedefinition/operatorconfigs.operator.external-secrets.io
   - customresourcedefinition/secretstores.external-secrets.io
   - customresourcedefinition/webhooks.generators.external-secrets.io

## Common Issues

### Operator installation stuck in Pending

This problem occurs when an previous installation of this operator was not property removed from the cluster.

To fix this, follow the steps described under **Uninstall** and try to install the operator.
