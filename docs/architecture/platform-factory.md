# Platform Factory

This repository now supports a factory-style workflow for OpenShift Dedicated on Google Cloud.

The factory model separates:

- shared defaults in `catalog/`
- cluster intent in `clusters/`
- reusable Terraform composition in `modules/`
- in-cluster lifecycle in `gitops/`

The provider-specific Terraform implementation now lives directly in the factory-facing modules:

- `modules/osd-gcp-infra/`
- `modules/osd-gcp-core/`
- `modules/osd-gcp-kubeconfig/`
- `modules/osd-gcp-acm-registration/`
- `gitops/bootstrap/`

The `modules/` layer composes the cluster-creation path, kubeconfig flow, ACM registration, and GitOps bootstrap into a single cluster stack so operators can work from one cluster directory instead of running each stage by hand.
