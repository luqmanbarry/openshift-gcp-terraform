# Portworx Storage

This chart gives you a starting point for a Portworx `StorageCluster`.

Safe defaults:

- the chart is off by default
- CSI is on inside the sample `StorageCluster`
- snapshot controller is on inside the sample `StorageCluster`
- Autopilot is off

Important note:

- Portworx recommends using its spec generator for real installs
- use this chart as a GitOps home for the final `StorageCluster` spec after you build it for your environment

Why this chart is simple:

- Portworx storage layout, disks, cloud access, and security settings are very environment-specific

Source used for the starter shape:

- Portworx says the main object is `StorageCluster`
- Portworx says the spec generator is the recommended way to build that object

Docs:

- https://docs.portworx.com/portworx-enterprise/reference/CRD/storage-cluster

Secrets:

- Store any Portworx credentials in Google Secret Manager or another approved backend and read them through ESO. Wire the chart values to the ESO secret names instead of committing secrets to Git.
