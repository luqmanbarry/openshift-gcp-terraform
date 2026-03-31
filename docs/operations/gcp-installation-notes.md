# GCP Installation Notes

Use `rosa-classic-terraform/` as the structural reference for repo layout and workflow, but keep Google Cloud behavior aligned with Red Hat's OpenShift Dedicated on GCP documentation.

Key points carried into this repo:

- Keep cluster networking aligned with the OpenShift Dedicated on GCP install guidance for `machineNetwork`, `clusterNetwork`, and `serviceNetwork`.
- Match the machine network CIDR to the preferred subnet CIDR.
- Avoid overlapping reserved ranges such as `172.17.0.0/16`.
- Support both installer-created networking and existing VPC patterns.
- Keep GCP IAM, service-account, and Workload Identity Federation concerns as provider-specific inputs, not as a separate repo structure.
- In this repo, those GCP-specific inputs are layered into the ROSA-style schema through `gcp_region`, `gcp_project_id`, `gcp_default_zone`, `network`, `infrastructure`, and `identity.gcp_workload_identity`.
- For GitOps-managed workload access to Google APIs, the repo defaults to `gitops.gcp_auth.mode: workload_identity_federation`. The legacy static service-account-key path is still supported, but only when explicitly selected with `gitops.gcp_auth.mode: service_account_key`.
- `infrastructure.create_gcp_resources` is the switch between Terraform-managed networking and customer-provided networking. When it is `false`, the cluster stack must point at an existing `network.vpc_name`, `network.master_subnet_name`, and `network.worker_subnet_name`.
- `cluster.private_service_connect_enabled` maps to the `ocm create cluster --psc-subnet` flow for private `OSD` on `GCP`. Because Red Hat supports PSC only with an existing VPC, the repo validates that PSC can only be used when `infrastructure.create_gcp_resources` is `false`.
- `openshift_version` is intentionally modeled as `x.y` to match the repo contract and avoid pinning patch releases in the Terraform inputs.
- The tracked cluster classes and sample cluster folders are intentionally incomplete until platform-specific values are provided. Validation rejects placeholder or empty values for required production inputs such as GCP project IDs, DNS domains, secret projects, and Git repository URLs.

Reference docs:

- OpenShift Dedicated clusters on GCP: https://docs.redhat.com/en/documentation/openshift_dedicated/4/html/openshift_dedicated_clusters_on_gcp/index
- Private Service Connect overview: https://docs.redhat.com/en/documentation/openshift_dedicated/4/html/openshift_dedicated_clusters_on_gcp/creating-a-gcp-psc-enabled-private-cluster
- Creating a cluster on GCP with Workload Identity Federation: https://docs.redhat.com/en/documentation/openshift_dedicated/4/html/openshift_dedicated_clusters_on_gcp/osd-creating-a-cluster-on-gcp-with-workload-identity-federation
