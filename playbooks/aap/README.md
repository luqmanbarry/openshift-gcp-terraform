# AAP

Use `run_cluster_stack.yml` to run the same validated workflow used by bastion and CI.

Common variables:

- `cluster_dir`: cluster path relative to the repo root
- `artifact_dir`: where rendered config, plans, and outputs are written
- `terraform_action`: `validate`, `plan`, or `apply`
- `backend_enabled`: whether to use remote state
- `backend_config_file`: optional backend config file path
- `allow_apply`: must be `true` for apply runs
