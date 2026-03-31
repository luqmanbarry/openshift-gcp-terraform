# GitOps

OpenShift GitOps keeps the OSD on GCP cluster configuration in sync after Terraform bootstrap. The layout now follows the same factory pattern used in `rosa-classic-terraform/`: bootstrap charts, a shared overlay, reusable platform charts, and reusable workload charts.

## GitOps Flow

1. Terraform installs the OpenShift GitOps operator.
2. Terraform creates the root Argo CD `Application` from `gitops/bootstrap/root-app/`.
3. The root app points to `gitops/overlays/cluster-applications/`.
4. The shared overlay creates the `platform` and `workloads` `AppProject` resources and their child applications.
5. Each child application syncs a chart from `gitops/apps/platform/` or `gitops/apps/workloads/`.

## Layout

- `bootstrap/`: charts used directly by Terraform bootstrap
- `apps/platform/`: reusable platform charts and operator starters
- `apps/workloads/`: reusable workload charts and workload starters
- `overlays/cluster-applications/`: shared app-of-apps overlay used by every cluster

## App Inventory

- The platform and workload app directories intentionally mirror the ROSA repo inventory so both repos use the same GitOps pattern.
- Existing GCP-capable charts were copied into `apps/`.
- Existing active app inventory now tracks the ROSA platform and workload layout directly, with GCP-specific implementation where cloud-specific behavior is required.

## Enabling Apps

- Each cluster selects apps in `clusters/<group-path>/<cluster>/gitops.yaml`.
- Each app reads its values from `clusters/<group-path>/<cluster>/values/`.
- Keep secrets out of Git. For this repo, the default secret flow is Google Secret Manager through External Secrets Operator.
