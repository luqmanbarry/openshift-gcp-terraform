# External Secrets Operator

This chart installs External Secrets Operator for OpenShift and can also create one shared `ClusterSecretStore`.

For this repo, the default provider direction is Google Secret Manager on OSD on GCP.

Recommended pattern:

- keep operator install in this chart
- keep shared `ClusterSecretStore` definitions in `external-secrets-config`
- keep app `ExternalSecret` objects with the app that uses them
- keep destructive cleanup disabled unless you are intentionally tearing down a dedicated cluster

`cleanupOnDelete.enabled` is `false` by default because the cleanup job deletes cluster-wide ESO resources and is not safe for shared production clusters.
