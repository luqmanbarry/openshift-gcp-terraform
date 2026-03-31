# Clusters

Each cluster lives under `clusters/<group-path>/<cluster-name>/`.

Required files:

- `cluster.yaml`: cluster intent and infrastructure settings.
- `gitops.yaml`: GitOps overlay inputs and selected applications.
- `main.tf`: Terraform entrypoint that consumes the rendered `stack`.
- `variables.tf`: input variables for the cluster entrypoint.

Generated files:

- `.artifacts/<run>/effective-config.json`
- `.artifacts/<run>/build-metadata.json`
- `.artifacts/<run>/terraform.auto.tfvars.json`
- `.artifacts/<run>/terraform-plan.txt`
- `.artifacts/<run>/terraform-outputs.json`

The recommended workflow is:

1. Update `cluster.yaml`, `gitops.yaml`, and any values files.
2. Run `scripts/run_cluster_stack_bastion.sh` or `scripts/run_cluster_workflow.sh`.
3. Review artifacts under `.artifacts/`.
4. Apply only after an approved plan and real environment values are in place.

Preferred `cluster.yaml` shape, aligned to the ROSA factory pattern:

- top-level placement keys such as `cluster_name`, `class_name`, `gcp_region`, `gcp_project_id`, and `gcp_default_zone`
- `business_metadata` for ownership and cost attribution
- `network` for VPC, subnet, DNS, and firewall intent
- `infrastructure` for create-vs-reuse choices
- `cluster` for machine type, scaling, privacy, and cluster networking
- `identity` for GCP workload identity settings
- `acm` for optional hub registration
- `gitops` for bootstrap controls and repository settings

Behavior notes:

- Set `infrastructure.create_gcp_resources: true` when Terraform should create the VPC and subnets through the factory `infra` path.
- Set `infrastructure.create_gcp_resources: false` when the customer provisions networking outside this repo.
- When reusing existing infrastructure, `network.vpc_name`, `network.master_subnet_name`, and `network.worker_subnet_name` must be provided in `cluster.yaml`.
- For the recommended private `OSD` on `GCP` path, set `cluster.private: true`, `cluster.private_service_connect_enabled: true`, `infrastructure.create_gcp_resources: false`, and provide `network.psc_subnet_name` in addition to the existing VPC and subnet names.
- `openshift_version` must use `x.y` format, for example `4.18`.
