# GitOps Apps

This directory mirrors the `rosa-classic-terraform/` GitOps application layout.

- `apps/platform/`: reusable platform-level GitOps charts for cluster services and operators
- `apps/workloads/`: reusable workload-level starter charts for shared tenant platforms

The GCP repo keeps the platform charts GCP-specific where cloud integration matters. Existing charts that have not yet been rewritten for GCP are scaffolded here as disabled starter charts so the directory pattern stays aligned with ROSA.
