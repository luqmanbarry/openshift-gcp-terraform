# OSD On GCP Factory

This repository builds and manages OpenShift Dedicated clusters on Google Cloud. Inputs live in Git, Terraform owns the GCP prerequisites and cluster bootstrap lifecycle, and OpenShift GitOps manages normal in-cluster changes.

## Repository Layout

- `catalog/`: shared defaults and cluster classes
- `clusters/`: one folder per cluster under `clusters/<group-path>/<cluster-name>/`
- `modules/`: factory-facing Terraform modules
- `gitops/`: OpenShift GitOps bootstrap and reusable day-2 applications
- `playbooks/`: Ansible Automation Platform examples
- `scripts/`: render, validate, backend, and workflow helper scripts
- `docs/`: architecture notes and execution guidance

## How It Works

1. Write or update `cluster.yaml`, `gitops.yaml`, and any values files under `clusters/<group-path>/<cluster-name>/`.
2. Render and validate the effective stack with `scripts/render_effective_config.py` and `scripts/validate_stack_inputs.py`.
3. Run Terraform through the workflow helpers rather than writing generated files back into the cluster folder.
4. Terraform composes the GCP infrastructure, cluster creation, kubeconfig setup, optional ACM registration, and optional GitOps bootstrap through the new factory path.
5. GitOps manages the platform and workload applications after the cluster is ready.

## Terraform Scope

- Optional GCP infrastructure creation through `modules/osd-gcp-infra/`
- OpenShift Dedicated cluster creation on GCP through `modules/osd-gcp-core/`
- Kubeconfig setup through `modules/osd-gcp-kubeconfig/`
- Optional ACM registration and OpenShift GitOps bootstrap through the factory path

`modules/osd-gcp-infra/` is optional. If networking is provisioned outside this repo, set `infrastructure.create_gcp_resources: false` and provide the existing VPC and subnet names in the cluster config.
For the current recommended private `OSD on GCP` model, also set `cluster.private_service_connect_enabled: true` and provide `network.psc_subnet_name`.

The `modules/` and `clusters/` layout is the operator-facing factory interface.

## Prerequisites

- `terraform`
- `python3`
- `gcloud`
- `ocm`
- `oc`
- `helm`
- `jq`
- network access to Red Hat OCM and the target GCP environment
- a GCP project with permission to create or reuse network, IAM, DNS, secret, and cluster resources
- Red Hat pull secret and OCM token stored in Google Secret Manager

## Execution Patterns

- Bastion or admin workstation:
  `scripts/run_cluster_stack_bastion.sh clusters/dev/gcp-classic-101 plan`
- Manual bastion apply:
  `OCP_GCP_FACTORY_ALLOW_APPLY=true scripts/run_cluster_stack_bastion.sh clusters/dev/gcp-classic-101 apply`
- GitHub Actions:
  `.github/workflows/factory.yml`
- Azure Pipelines:
  `azure-pipelines.yml`
- AAP:
  `playbooks/aap/run_cluster_stack.yml`

Rendered files, plans, backend config files, and workflow outputs should go under `.artifacts/` instead of mixing generated files into source directories.

For remote state, cluster roots declare a `gcs` backend and the workflow helpers expect backend settings through environment variables such as `TF_BACKEND_BUCKET` and optional `TF_BACKEND_PREFIX`.

The tracked files under `catalog/` and `clusters/` are starter configurations, not production values. Validation now rejects placeholder or empty values for required production inputs such as:

- `gcp_project_id`
- `network.base_dns_domain`
- `secrets.pull_secret_secret_project`
- `secrets.git_token_secret_project`
- `gitops.repository_url`

## GCP Notes

- Keep GCP-specific networking aligned with OpenShift Dedicated on GCP guidance. Red Hat’s installation docs for GCP networking call out matching `machineNetwork` to the preferred subnet CIDR and avoiding overlapping reserved ranges such as `172.17.0.0/16`.
- Treat Workload Identity Federation, project IAM, and GCP network CIDRs as provider-specific inputs layered under the ROSA-style factory structure rather than inventing a separate repo shape.
- For GitOps-managed workloads, this repo now defaults to Kubernetes-to-Google `workload_identity_federation` and keeps the static service-account-key path available only through `gitops.gcp_auth.mode: service_account_key`.
- Use `openshift_version` in `x.y` form, for example `4.18`, rather than full patch strings in the Terraform-facing config.

## Read More

- [Platform factory](docs/architecture/platform-factory.md)
- [Terraform vs GitOps boundary](docs/architecture/terraform-vs-gitops-boundary.md)
- [Execution models](docs/operations/execution-models.md)
- [GCP installation notes](docs/operations/gcp-installation-notes.md)
- [Implementation plan](docs/operations/implementation-plan.md)
- [Tenant onboarding](docs/operations/tenant-onboarding.md)
- [Catalog](catalog/README.md)
- [Clusters](clusters/README.md)
- [Terraform modules](modules/README.md)
- [GitOps](gitops/README.md)
- [AAP playbooks](playbooks/README.md)
