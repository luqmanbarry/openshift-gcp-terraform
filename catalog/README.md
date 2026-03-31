# Catalog

The catalog holds reusable defaults for cluster classes and machine-pool classes.

- `cluster-classes/`: baseline settings for environments such as `dev`, `qa`, and `prod`.
- `machine-pool-classes/`: optional reusable worker-pool definitions for GitOps or future Terraform expansion.

Cluster folders in `clusters/` select a `class_name`, and the render step merges that class with the cluster-specific overrides from `cluster.yaml` and `gitops.yaml`.
