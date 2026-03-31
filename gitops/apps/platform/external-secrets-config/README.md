# external-secrets-config

This chart configures shared External Secrets Operator settings for this repo.

For the GCP factory, the default pattern is:

- Google Secret Manager as the backend
- one shared `ClusterSecretStore` called `platform-secrets`
- app `ExternalSecret` objects that reference that shared store

Use it for shared ESO platform configuration, not as the normal place for app-specific `ExternalSecret` resources.
