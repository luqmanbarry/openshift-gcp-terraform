# Modules

The `modules/` directory provides factory-facing Terraform modules.

- `factory-stack/`: top-level composition module for a single cluster stack.
- `osd-gcp-infra/`: optional GCP infrastructure bootstrap.
- `osd-gcp-core/`: OpenShift Dedicated cluster creation on GCP.
- `osd-gcp-kubeconfig/`: managed-cluster and ACM hub kubeconfig materialization.
- `osd-gcp-acm-registration/`: ACM managed-cluster registration.
- `openshift-gitops-bootstrap/`: wrapper around `gitops/bootstrap/`.
