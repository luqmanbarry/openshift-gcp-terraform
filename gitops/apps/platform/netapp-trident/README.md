# NetApp Trident

This chart helps you start a NetApp Trident setup on OpenShift.

It can do two jobs:

- install the certified operator through OperatorHub
- create a `TridentOrchestrator` custom resource

Safe defaults:

- operator install is off
- `TridentOrchestrator` is off
- operator install plan approval is `Manual`

Why these defaults are off:

- Trident needs storage backend details that are specific to your environment
- some Trident features need extra node prep, such as iSCSI

Good first step:

1. enable the operator install
2. install Trident
3. add backend and storage class settings after the operator is healthy

Source used for the starter shape:

- NetApp says to use the certified OpenShift operator and then create a `TridentOrchestrator` resource
- NetApp also notes that some node prep features need newer Trident versions on newer OpenShift releases

Docs:

- https://docs.netapp.com/us-en/trident-2506/trident-get-started/openshift-operator-deploy.html

Secrets:

- Store any credentials that Trident needs in Google Secret Manager or another approved backend and sync them using ESO. Point the chart values at the ESO secret name instead of pasting credentials into Git.
