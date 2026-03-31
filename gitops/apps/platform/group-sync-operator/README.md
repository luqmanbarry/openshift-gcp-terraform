# group-sync-operator

This chart installs the Group Sync Operator and configures one `GroupSync` resource.

The chart is provider-neutral at the values layer and assumes secrets come from the configured `ClusterSecretStore`, which for this repo is typically backed by Google Secret Manager.

Supported providers in this chart:

- `azure`
- `github`
- `gitlab`
- `keycloak`
- `okta`
- `ibmsecurityverify`
