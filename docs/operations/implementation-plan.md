# Implementation Plan

## Day 0

- Define cluster classes in `catalog/cluster-classes/`.
- Create a cluster folder under `clusters/<group-path>/<cluster-name>/`.
- Render and validate the stack inputs.

## Day 1

- Run the cluster Terraform stack through `modules/factory-stack`.
- Create or reuse GCP networking.
- Install the OCP cluster on GCP.
- Publish kubeconfig access, DNS/TLS bootstrap, ACM bootstrap, and GitOps bootstrap as configured.

## Day 2

- Manage ongoing platform and workload configuration through `gitops/`.
- Keep per-cluster values in the cluster directory and shared charts in `gitops/`.
