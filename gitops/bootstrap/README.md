# GitOps Bootstrap

This directory contains the bootstrap charts used by Terraform:

- `openshift-gitops/`: installs the OpenShift GitOps operator
- `root-app/`: creates the root Argo CD `Application`

Bootstrap authentication notes:

- this module creates a dedicated GCP service account plus a rotated `credentials.json` secret for bootstrap and early day-2 integrations
- it does not create a custom workload identity pool or provider
- workload identity for application service accounts should be modeled separately and only when the cluster issuer and token flow are intentionally configured for that pattern
