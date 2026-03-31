# oadp-operator

This chart installs the OADP Operator and configures a `DataProtectionApplication` for OSD/OCP on GCP.

The active chart in this repo assumes:

- backup storage is Google Cloud Storage
- credentials are delivered through External Secrets Operator from the configured `ClusterSecretStore`
- the referenced remote secret contains the GCP credential content to place under the Velero credentials key, typically `cloud`

By default the chart is set up for filesystem backup. If you disable `defaultVolumesToFsBackup`, the chart also renders a GCP snapshot location and a hook job that marks the configured `VolumeSnapshotClass` for Velero CSI use.
