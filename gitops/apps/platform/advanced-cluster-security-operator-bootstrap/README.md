# OpenShift Container Security

This chart installs the Advanced Cluster Security operator resources.

Use it when you want GitOps to create the namespace, `OperatorGroup`, and `Subscription`.

Before you enable it:

- up and running OSD on GCP cluster
- approved operator version and channel
- cluster sizing that fits ACS components
- install plan approval is `Manual` by default so upgrades are reviewed
