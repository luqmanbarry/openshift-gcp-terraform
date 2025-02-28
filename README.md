# ARO Classic cluster automation

## Pre-Requisites

### Account Level
- [Detailed List](https://cloud.redhat.com/experts/aro/prereq-list/)

### Execution Level
- User/ServicePrincipal with permission to:
  - Create ResourceGroups, VirtualNetworks, Subnets, VMs..etc
  - Create Storage Account
  - Create, Delete ARO
  - Create a DNS Zone and add A, DNS records to it
- Virtual Network (VNet) 
- Subnets tagged with `cluster_name`
  - `x.x.x.x/24` CIDR for Multi-AZ
  - `x.x.x.x/25` CIDR for Single-AZ
  
- Optional: Base DNS Domain name (ie: sama-wat.com) - This is required unless you're using the Azure CLI.
- Optional: Base DNS Zone deployed with resulting name servers registered to the domain registrar. It's name or subdomain name should match the base_dns_zone name.
- ARO [pull-secret](https://console.redhat.com/openshift/downloads#tool-pull-secret)
  - Place the pull-secret json string in Azure KeyVault and set the `TF_VAR_ocp_pull_secret_kv_secret` with the name of the KV secret name.
  
    For example: 
    ```sh
    export TF_VAR_ocp_pull_secret_kv_secret="aro-pull-secret"
    ```
- Network security group inbound rules defined; this is to allow traffic from parties that need to connect to the cluster. For example, the CI/CD platform hosts, and any other IP ranges that will try to reach the cluster.

### Software Packages
- [GoLang](https://go.dev/doc/install) - 1.20.x or greater
- [Terraform](https://developer.hashicorp.com/terraform/install#linux) 1.5.x or greater
- Up to date [Openshift Client](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Helm](https://helm.sh/docs/intro/install/)
- [jq](https://jqlang.github.io/jq/download/)

## Execution Flow

![ARO Build Stages](.assets/aro-classic-automation-steps-v2.jpg)


## Admin variables

These are the cross-module [variables](./tfvars/admin/admin.tfvars) that are common across business units.

## User input variables

[Variables](.ci/user-inputs.sh) the user provides during the execution of the pipeline.

## Derived variables

These are the [variables](./tfvars-prep/variables.tf) that change based on user inputs.

## Custom domain TLS certificates

The guide uses the [cert-manager](https://docs.openshift.com/container-platform/4.14/security/cert_manager_operator/index.html) operator to automate custom domain TLS/SSL certificates creation, rollout and rotation.

To learn the logic behind the implementation, read [this](https://cloud.redhat.com/experts/aro/cert-manager/) article.

## Terraform Modules

Listed in their order of precedence, they work together to provision an ARO cluster, make necessary configurations and then register the cluster to ACM for day-2 configurations and management. However, by default the CI pipeline script does not do ACM-HUB registration, instead it deploys the OpenShift GitOps operator (ArgoCD), apply the necessary configurations such as adding a repository, RBAC configuration. The day-2 GitOps configuration code is located inside the [gitops](./gitops/) directory.

- [tfstate-config](./tfstate-config/): Create a storage account and storage container for remote state storage.
- [key-vault](./key-vault/): Create an Azure KeyVault instance dedicated to this cluster; cluster details (admin_username, admin_password, console_url, api_server_url, ingress_lb_ip, api_server_lb_ip) will be stored there as KeyVault secrets.
  - This module needs to run only if the Vault instance does not exists. We only need one instance per Business Unit & Environment; however, the setup can be modified to one per BU/Env/Cluster; or per the customer requirements.
- [aro-infra](./aro-infra/): This module deploys the infrastructure resources that must exist before a cluster can be deployed. The following resources will be created: ResourceGroup, VirtualNetworks, Control & Worker Subnets, NetworkSecurityGroup to allow traffic from the CICD/Bastion hosts, and a ServicePrincipal with required roles for the cluster.
- [tfvars-prep](./tfvars-prep/): Combine admin, user inputs, and derived variables into a master tfvars file. All subsequent modules will use that file.
- [git-tfvars-file](./git-tfvars-file/): Commit the master tfvars file to GitHub. Feel free to change the repo location to GitLab, BitBucket...etc.
- [aro-classic](./rosa-classic/): Creates the ARO cluster, save the cluster details to Azure KeyVault Secrets, and then add two "A" records the child DNS zone for Ingress and API.
- [dns-tls-certs](./dns-tls-certs/): For the purpose of simplicity, I am assuming the TLS/SSL certificates are uploaded to an Azure KeyVault Certificates instance; I have seen this setup often with customers, hence why I am doing it this way. The module will download these certificates and then deploy them onto the ARO cluster.
  - Note, deploying the TLS certificates for the custom domain should be part of day-2 configurations using GitOps practices. Read [here](https://cloud.redhat.com/experts/aro/cert-manager/) to learn more.
- [acmhub-registration](./acmhub-registration/): Registers the ARO cluster to  ACM-HUB.
- [gitops/bootstrap](./gitops/bootstrap/): Deploys and configure the OpenShift GitOps operator. Configurations such as adding a repository, RBAC, App of apps pattern are configured after the Operator deployment.

  ![Day-2 GitOps Architecture](.assets/tf-day2-gitops-architecture.jpg)

  - [gitops/modules](./gitops/modules/): Cluster Day2 configuration items are implemented using GitOps patterns. Each configuration item represents a module packaged as a Helm chart.
  - [gitops/argocd-apps](./gitops/argocd-apps/): The Helm chart that defines the ArgoCD applications manifests used for the deployment of the Day2 configuration modules; one ArgoCD `Application` CR per Day2 module.

## Cluster Build

### 1. GitHub repository and PAT token

For the pipeline to work end-to-end, a Git (public/private) repository is required. If the repository is private, a PAT token with write access to the repository is required as well.

> [!NOTE]
> 
> It does not have to be GitHub SCM only. We can switch SCM providers by updating the [git-tfvars-file](./git-tfvars-file/); replacing the GitHub specific configs by whatever SCM vendor we want.

### 2. Optional: Provision the base domain DNS Zone

This step is only required in the absence of a DNS Zone instance. In a production environment, the root DNS zone would already exist.

1. Create the Base DNS Zone instance

    This step should be skipped if there is a base DNS Zone already setup. Keep in mind, the base DNS Zone could be a child zone to the root zone.

    ![Azure Base DNS Zone Create](.assets/base-dns-zone-create.png)

2. Record the DNS Zone assigned name servers

    ![Azure Base DNS Zone Details](.assets/base-dns-zone-details.png)

3. Delegate the name servers to your domain registrar

    ![GoDaddy domain delegation](.assets/godaddy-base-dns-zone-transfer.png)

4. Verify root DNS Zone domain is resolvable

    ```sh
    nslookup -type=NS openshift.sama-wat.com

    Server:         100.64.100.1
    Address:        100.64.100.1#53

    Non-authoritative answer:
    openshift.sama-wat.com  nameserver = ns1-02.azure-dns.com.
    openshift.sama-wat.com  nameserver = ns2-02.azure-dns.net.
    openshift.sama-wat.com  nameserver = ns3-02.azure-dns.org.
    openshift.sama-wat.com  nameserver = ns4-02.azure-dns.info.

    Authoritative answers can be found from:
    ```

### 3. Optional: Register cluster dedicated child DNS Zone name servers to domain registrar

> [!NOTE]
> 
> This step would be implemented differently in the case of a private cluster; however, the logic would remain pretty much the same.

As part of the cluster build, the automation script will create child DNS zone instance, add an NS record fo the child DNS Zone to the base DNS Zone. The DNS zone transfer to the domain register is not automated; this step could be automated as well.

Domain patterns:

- Child DNS Zone: `<cluster_name>.<platform_environment>.<location>.<organization>.<base_dns_zone_name>`

- API Server domain: `api.<cluster_name>.<platform_environment>.<location>.<organization>.<base_dns_zone_name>`

- Console URL domain: `console-openshift-console.apps.<cluster_name>.<platform_environment>.<location>.<organization>.<base_dns_zone_name>`

- Default routes domain: `*.apps.<cluster_name>.<platform_environment>.<location>.<organization>.<base_dns_zone_name>`

1. Child DNS Zone details

    ![Cluster child DNS Zone](.assets/cluster-dns-zone-details.png)

2. Register the cluster child DNS Zone to domain registrar

    ![Cluster child DNS Zone transfer](.assets/godaddy-cluster-dns-zone-transfer.png)

3. Verify Cluster (child) DNS Zone domain is resolvable
   
    ```sh
    nslookup -type=NS aro-classic-101.dev.eastus.poc2357.openshift.sama-wat.com
    Server:         100.64.100.1
    Address:        100.64.100.1#53

    Non-authoritative answer:
    aro-classic-101.dev.eastus.poc2357.openshift.sama-wat.com       nameserver = ns1-06.azure-dns.com.
    aro-classic-101.dev.eastus.poc2357.openshift.sama-wat.com       nameserver = ns2-06.azure-dns.net.
    aro-classic-101.dev.eastus.poc2357.openshift.sama-wat.com       nameserver = ns3-06.azure-dns.org.
    aro-classic-101.dev.eastus.poc2357.openshift.sama-wat.com       nameserver = ns4-06.azure-dns.info.

    Authoritative answers can be found from:
    ```

> [!IMPORTANT] 
> 
> Ensure the base and child domains are resolvable before going further; or else all stages after cluster provisioning will fail because they will not be able to resolve the API server hostname.


### 4. Provision the Azure KeyVault instance

I have added a module for deploying a business unit dedicated KeyVault instance. Cluster details (admin_username, admin_password, console_url, api_server_url, ingress_lb_ip, api_server_lb_ip) will be stored there as KeyVault secrets.

This module only needs to run if the Vault instance does not exists. We need one instance per Business Unit & Environment; however, the setup can be modified to one per BU/Env/Cluster; or per the customer requirements.

### 5. Optional: Save ACM-HUB cluster credentials in KeyVault secrets

If the cluster is meant to be managed by ACM-HUB, there is a module that will register the cluster to ACM. However, as the cluster credentials will be fetched by the module, the HUB cluster credentials must be placed in KeyVault Secret with a name matching this pattern: `openshift-<OCP_ENV>-acmhub-<ACMHUB_CLUSTER_NAME>`.

The value of the secret must be of json format with the following fields set:

```yaml
{
  "admin_username": "value",
  "admin_password": "value",
  "api_server_url": "value"
}
```

### 6. Verify Admin variables are correct

Admin tfvars file is available [here](./tfvars/admin/admin.tfvars).

### 7. Prepare user inputs

Use the [user-inputs.sh](./.ci/user-inputs.sh) file as reference. All parameters shown in there collectively represent what the user is expected to provide at each pipeline execution. More parameters can be provided if the user opts to shift more parameters to be provided at runtime.

### 8. Execute the cluster provisioning pipeline

For the cluster to be accessible at the console, api urls, the name servers of the child DNS Zone instance dedicated to the cluster need to be registered in the DNS instance hosting the NS records of the root domain. 

> [!IMPORTANT]
> 
> After the `aro-infra` module, if you've enabled custom domain, the [pipeline-create](.ci/pipeline-create.sh) script will wait for the user to confirm whether they have added NS records for the cluster dedicated DNS Zone to the registrar (ARO public) or to the self-managed DNS instance.



```sh
.ci/pipeline-create.sh .ci/user-inputs.sh | tee aro-classic-create.log
```

## Cluster Teardown

```sh
.ci/pipeline-destroy.sh .ci/user-inputs.sh | tee aro-classic-destroy.log
```