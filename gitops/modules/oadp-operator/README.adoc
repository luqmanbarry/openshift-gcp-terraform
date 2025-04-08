= DevOp toolchain + OADP

The code is designed to support Pod FileSystemBackup, CSI Snapshot with SnapShotMoveData which copies snapshots to the storage account, CSI Snapshot with keeps snapshots within the ARO cluster managed resource group. 

The Pod FSB is activated by default. Set the `defaultVolumesToFSBackup: false` to activate CSI Snapshot.

Three Helm based GitOps modules are used to achieve this setup:

. oadp-operator: Install the OADP Operator, configures the `DataProtectionApplication` custom resource. 
.. The Helm chart uses an https://external-secrets.io/latest/provider/azure-key-vault/#creating-external-secret[ExternalSecret] CR to read the Service Principal ClientSecret from Azure KeyVault and place it in a Kubernetes secret object for the `BackupStorageLocation` CR configuration.
.. To learn how the ESO was deployed, here's the [external-secret operator](../external-secrets-operator/) module.
. oadp-backup: Create the `Schedule` CRs, one per namespace, which are used to trigger periodic namespace backups.
. oadp-restore: Create the `Restore` CRs, one per backup, they are used to restore backups.

== Prerequisites

* Azure Red Hat OpenShift cluster.
** One cluster if you want to test restore on the same cluster.
** Two clusters for testing restore on a completely different cluster.
* OpenShift GitOps instance deployed.
** This applies to the backup and restore clusters.
* Ensure network traffic between the backup cluster and the storage account is allowed; as well as traffic between restore cluster and the storage account.
* Test applications up and running on the backup cluster
* https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure[Prepare the Velero Azure Service Principal]
** Multiple options are available, I chose to use a Service Principal with a custom role (velero) assigned to it.
* Store the Service Principal ClientSecret to Azure Key Vault

== Procedure

Each of the 3 OADP Hem charts is deployed and monitored by an ArgoCD Application that is defined in the `argocd-apps` helm chart. Distinct ArgoCD applications parameters are provided in the values file. Use the `values.<cluster-name>.yaml` as reference.

=== Backup

. Install the `oadp-operator` helm chart.
+
.. Register the `oadp-operator` ArgoCD Application
+
[source,yaml]
----
modules:
  - name: oadp-operator
    config_path: gitops/modules/oadp-operator
    sync_wave: 113
----
+
. Verify applications being backed up are healthy and all volumes mounted.
. Identity the namespaces you want backed up and provide their names in the `oadp-backup` module's `values.<cluster-name>.yaml` file. 
.. The `oadp-backup` module takes periodic backup of selected namespaces.
.. Taking into account the local time zone, you should update the backup `cronSchedule` to your requirements, for example once daily at midnight (`0 0 * * *`). UTC is the default TZ.
. Deploy the `oadp-backup` module.
.. Register the `oadp-backup` ArgoCD Application
+
[source,yaml]
----
modules:
  - name: oadp-backup
    config_path: gitops/modules/oadp-backup
    sync_wave: 113
----
+
. Wait for the backup to complete.

=== Restore

The restore can be applied to different scenarios.
* Restoring backups on the same cluster where they were taken.
* Restoring backups on a different cluster, same or different region.

. Install the `oadp-operator`.
.. **Skip** this step if the restore operation is taking place in the backup cluster.
. Wait for the backups to be synchronized on the new/existing cluster. For this work on a completely new cluster, the `BackupStorageLocation` CR must point to the same storage account & container.
. Identify the backups you want restored and provide their names in the `oadp-restore` module's `values.<cluster-name>.yaml` file.
. Deploy the `oadp-restore` module.
.. Register the `oadp-restore` ArgoCD Application
+
[source,yaml]
----
modules:
  - name: oadp-restore
    config_path: gitops/modules/oadp-restore
    sync_wave: 113
----
+
. Wait for the restore to complete.