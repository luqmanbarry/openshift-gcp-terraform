# Tenant Onboarding

Tenant onboarding should stay in GitOps, not in Terraform.

Recommended pattern:

1. Platform administrators create the cluster and bootstrap GitOps.
2. Shared platform applications are enabled through `gitops.yaml` and cluster values files.
3. Tenant namespaces, quotas, RBAC, and application repos are added through GitOps modules after cluster readiness.
