# OpenShift Day2 configuration using GitOps

## Architecture

![Day-2 GitOps Architecture](.assets/tf-day2-gitops-architecture.jpg)


## Sub Directories

- [gitops/bootstrap](./gitops/bootstrap/): Deploys and configure the OpenShift GitOps operator. Configurations such as adding a repository, RBAC, App of apps pattern are configured after the Operator deployment.

- [gitops/modules](./gitops/modules/): Cluster Day2 configuration items are implemented using GitOps patterns. Each configuration item represents a module packaged as a Helm chart.
- [gitops/argocd-apps](./gitops/argocd-apps/): The Helm chart that defines the ArgoCD applications manifests used for the deployment of the Day2 configuration modules; one helm chart per Day2 module.

## Pre-requisites
- ARO Cluster
- Azure KeyVault
- Azure Storage Account
- Bastion host with these packages: openshift-client, azure-cli, terraform, helm, jq, python3

## Procedure

1. Deactivate all ArgoCD Application
   - At first deactivate all modules except the openshift-gitops module. Use the `values.<cluster-name>.yaml` file of the [argocd-apps](./argocd-apps/) helm chart.
      ```yaml
      clusterName: 'aroclassic102'

      git:
        targetRevision: main

      # Helm does not support merge for variables of type list. 
      # The complete list have be provided if variable specified.
      modules: # List of modules to be deployed
        - name: openshift-gitops
          config_path: gitops/bootstrap/openshift-gitops
          sync_wave: 1
        - name: argocd-config
          config_path: gitops/bootstrap/argocd-config
          sync_wave: 100
        # - name: external-secrets-operator
        #   config_path: gitops/modules/external-secrets-operator
        #   sync_wave: 101
        # - name: secrets-store-csi-driver
        #   config_path: gitops/modules/secrets-store-csi-driver
        #   sync_wave: 101
        # - name: openshift-compliance
        #   config_path: gitops/modules/compliance-operator
        #   sync_wave: 102
        # - name: container-security
        #   config_path: gitops/modules/container-security
        #   sync_wave: 103
        # - name: internal-image-registry
        #   config_path: gitops/modules/internal-image-registry
        #   sync_wave: 104
        # - name: self-provisioner
        #   config_path: gitops/modules/self-provisioner
        #   sync_wave: 105
        # - name: user-workload-monitoring
        #   config_path: gitops/modules/user-workload-monitoring
        #   sync_wave: 106
        # - name: image-registries-allow-deny
        #   config_path: gitops/modules/image-registries-allow-deny
        #   sync_wave: 107
        # - name: global-cluster-pull-secret
        #   config_path: gitops/modules/global-cluster-pull-secret
        #   sync_wave: 108
        # - name: image-registries-proxy
        #   config_path: gitops/modules/image-registries-proxy
        #   sync_wave: 109
        # - name: cluster-log-forwarder
        #   config_path: gitops/modules/cluster-log-forwarder
        #   sync_wave: 110
        # - name: gitlab-runners
        #   config_path: gitops/modules/gitlab-runners
        #   sync_wave: 110
        # - name: splunk-log-forwarder
        #   config_path: gitops/modules/splunk-log-forwarder
        #   sync_wave: 110
        # - name: identity-providers
        #   config_path: gitops/modules/identity-providers
        #   sync_wave: 111
        # - name: groups-rbac
        #   config_path: gitops/modules/groups-rbac
        #   sync_wave: 112
        # - name: oadp-operator
        #   config_path: gitops/modules/oadp-operator
        #   sync_wave: 113
        # - name: sample-apps
        #   config_path: gitops/modules/sample-apps
        #   sync_wave: 114 
        # - name: oadp-backup
        #   config_path: gitops/modules/oadp-backup
        #   sync_wave: 115
        # - name: oadp-restore
        #   config_path: gitops/modules/oadp-restore
        #   sync_wave: 999
      ```
2. Deploy the OpenShift GitOps operator.
   Deployment and configuration codes are defined in the [bootstrap](./bootstrap/) sub-directory.

   > [!INFO]
   > We could use Ansible to achieve the same level of automation by swapping the Terraform code by Ansible.

3. Prepare the [Day2 configuration modules](./modules/) parameters. Use the `values.<cluster-name>.yaml` file for each cluster.

4. Activate the modules as they become ready for deployment.

    For example, the external-secrets-operator should be the first operator deployed after configuring ArgoCD.

    After having set the ESO inputs in the `values.<cluster-name>.yaml` file, we'll activate it for deployment on the cluster.

    ```yaml
    clusterName: 'aroclassic102'

    git:
      targetRevision: main

    # Helm does not support merge for variables of type list. 
    # The complete list have be provided if variable specified.
    modules: # List of modules to be deployed
      - name: openshift-gitops
        config_path: gitops/bootstrap/openshift-gitops
        sync_wave: 1
      - name: argocd-config
        config_path: gitops/bootstrap/argocd-config
        sync_wave: 100
      - name: external-secrets-operator
        config_path: gitops/modules/external-secrets-operator
        sync_wave: 101
      - name: secrets-store-csi-driver
        config_path: gitops/modules/secrets-store-csi-driver
        sync_wave: 101
      # - name: openshift-compliance
      #   config_path: gitops/modules/compliance-operator
      #   sync_wave: 102
      # - name: container-security
      #   config_path: gitops/modules/container-security
      #   sync_wave: 103
      # - name: internal-image-registry
      #   config_path: gitops/modules/internal-image-registry
      #   sync_wave: 104
      # - name: self-provisioner
      #   config_path: gitops/modules/self-provisioner
      #   sync_wave: 105
      # - name: user-workload-monitoring
      #   config_path: gitops/modules/user-workload-monitoring
      #   sync_wave: 106
      # - name: image-registries-allow-deny
      #   config_path: gitops/modules/image-registries-allow-deny
      #   sync_wave: 107
      # - name: global-cluster-pull-secret
      #   config_path: gitops/modules/global-cluster-pull-secret
      #   sync_wave: 108
      # - name: image-registries-proxy
      #   config_path: gitops/modules/image-registries-proxy
      #   sync_wave: 109
      # - name: cluster-log-forwarder
      #   config_path: gitops/modules/cluster-log-forwarder
      #   sync_wave: 110
      # - name: gitlab-runners
      #   config_path: gitops/modules/gitlab-runners
      #   sync_wave: 110
      # - name: splunk-log-forwarder
      #   config_path: gitops/modules/splunk-log-forwarder
      #   sync_wave: 110
      # - name: identity-providers
      #   config_path: gitops/modules/identity-providers
      #   sync_wave: 111
      # - name: groups-rbac
      #   config_path: gitops/modules/groups-rbac
      #   sync_wave: 112
      # - name: oadp-operator
      #   config_path: gitops/modules/oadp-operator
      #   sync_wave: 113
      # - name: sample-apps
      #   config_path: gitops/modules/sample-apps
      #   sync_wave: 114 
      # - name: oadp-backup
      #   config_path: gitops/modules/oadp-backup
      #   sync_wave: 115
      # - name: oadp-restore
      #   config_path: gitops/modules/oadp-restore
      #   sync_wave: 999
  
    ```
