# NFS CSI

This chart creates an NFS CSI `StorageClass`.

Safe defaults:

- the storage class is off by default
- volume expansion is on
- the NFS server and export path are empty

Important note:

- this chart does not install the NFS CSI driver
- use it when the driver already exists in the cluster and you want GitOps to manage the `StorageClass`

Good first step:

1. install or confirm the NFS CSI driver
2. set the NFS server and export path
3. enable the storage class

The chart fails fast if you enable the storage class without both values.

Source used for the starter shape:

- the upstream NFS CSI driver uses `nfs.csi.k8s.io` as the provisioner and `server` and `share` parameters in the `StorageClass`

Docs:

- https://kubernetes-csi.github.io/docs/drivers.html

Secrets:

- If the StorageClass needs credentials (for example, if it pulls from an ESO-synced secret) keep those secrets in Google Secret Manager or another approved backend and reference them via ESO names.
