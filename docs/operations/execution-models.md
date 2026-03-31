# Execution Models

## Bastion Or Admin Workstation

Use the bastion wrapper so rendered config, plans, and outputs stay under `.artifacts/` and not inside the cluster source directory.

Examples:

1. Validate:
   `scripts/run_cluster_stack_bastion.sh clusters/dev/gcp-classic-101 validate`
2. Plan:
   `scripts/run_cluster_stack_bastion.sh clusters/dev/gcp-classic-101 plan`
3. Apply:
   `OCP_GCP_FACTORY_ALLOW_APPLY=true scripts/run_cluster_stack_bastion.sh clusters/dev/gcp-classic-101 apply`

## GitHub Actions

Use `.github/workflows/factory.yml`.

- Pull requests run changed-cluster validation.
- Pushes to `main` run changed-cluster validation and plan.
- Manual runs support `validate`, `plan`, and `apply`.
- `apply` is manual only and requires `cluster_dir` to be set.

## Azure Pipelines

Use `azure-pipelines.yml`.

- Set `workflow_mode=plan` to run validation and plan.
- Set `workflow_mode=apply` to run validation, plan, and apply.
- Set `cluster_dir_override` for a single-cluster run.

## Ansible Automation Platform

Use `playbooks/aap/run_cluster_stack.yml` to call the same workflow helper used by bastion and CI.

Key variables:

- `cluster_dir`
- `artifact_dir`
- `terraform_action`
- `backend_enabled`
- `backend_config_file`
- `allow_apply`
