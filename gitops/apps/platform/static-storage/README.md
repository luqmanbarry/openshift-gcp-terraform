# Static Storage Provisioning

This chart manages a static PV/PVC pair for RWX workloads that keep their data on long-lived exports (for example, apps migrated from VMs that still use on-prem NFS).

How it works:

- PV: points to an existing backend export (NFS, etc.).
- PVC: claims the PV with the desired namespace and claim name.
- The PV and PVC stay disabled until you explicitly enable them.

Default sample values keep everything disabled and offer placeholders for the backend host/path and claim settings.

Safe defaults:

- PV is off
- PVC is off
- NFS server and path are empty
- PVC namespace is empty

The chart fails fast if you enable it without the required backend path or tenant namespace.

Use cases:

1. An app team needs a RWX share that already exists on-prem but must be accessible from the OSD on GCP cluster.
2. You want admins to approve a PV before workloads mount it; they enable the PV first, then the app team enables the PVC later.

Namespaces:

- Set `pvc.namespace` to the tenant namespace where the workload runs.
- Each tenant chooses its own namespace; do not use `default`.

Secrets and credentials:

- ESO should create Secrets containing backend credentials.
- Fill `pv.csi.nodeStageSecretRef` with that Secret name/namespace.
- This chart never stores Secrets in Git; it only references them.

Enabling the module:

1. Fill in `clusters/<group-path>/<cluster>/values/static-storage.yaml` with the real NFS/CSI backend, namespaces, and Secrets.
2. Set `pv.namespace` + `pvc.namespace` to the target tenant namespace.
3. Change `pv.csi.enabled`/`pvc.enabled` to `true`.
4. Enable the app in `gitops.yaml` and merge the change.

Prerequisites:

- backend export (NFS/S3/CSI) already exists and is accessible from the cluster.
- ESO Secret for backend credentials (`pv.csi.nodeStageSecretRef`).

Docs:

- CSI static provisioning guide: https://kubernetes.io/docs/concepts/storage/storage-classes/#static
