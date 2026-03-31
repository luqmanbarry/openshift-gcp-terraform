# service-account-annotations

This chart manages annotations on Kubernetes `ServiceAccount` objects.

Main use in this repo:

- annotate service accounts with GCP or platform integration annotations
- especially service accounts that need platform-specific metadata not exposed by the owning chart

Use it when a chart does not expose `serviceAccount.annotations` directly.
