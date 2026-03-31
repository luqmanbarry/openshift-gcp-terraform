# Terraform Vs GitOps Boundary

Terraform is responsible for:

- creating or reusing GCP networking for the cluster
- creating the OpenShift cluster
- publishing cluster connection details
- preparing kubeconfig access
- kubeconfig setup for follow-on admin actions
- optional ACM registration and OpenShift GitOps bootstrap from the factory stack

GitOps is responsible for:

- ongoing in-cluster application and platform configuration
- identity provider definitions
- registry, logging, storage, and day-2 operator configuration
- workload onboarding after the cluster is reachable

Keep long-lived platform configuration in `gitops/`. Keep cloud primitives and one-time bootstrap actions in Terraform.
