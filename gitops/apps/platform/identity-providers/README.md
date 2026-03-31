# identity-providers

This chart manages OpenShift OAuth identity provider configuration for the cluster.

The active implementation in this repo is provider-neutral at the values layer and is currently centered on OpenID Connect. Client secrets are expected to come from the configured `ClusterSecretStore`, which for this repo is typically backed by Google Secret Manager through External Secrets Operator.

Use cluster-specific values files to enable one or more OIDC providers and set issuer URLs, client IDs, scopes, and claim mappings.
