# OpenShift Cluster Log Forwarder

This helm chart deploys the openshift cluster-logforwarder operator and configures the `ClusterLogForwarder` CR to forward logs (app, audit, infra) to Splunk.

INFO: At the time of writing this code, the log forwarding was not working due to a bug. The bug has been reported.

## Inputs

Required inputs are defined in the [values.yaml](./values.yaml) file of the helm chart. 

The recommended pattern is to keep all common (defaults) parameters set in the `values.yaml` and overwrite params that change per cluster in the `values.cluster-name.yaml` file.

## Dependencies

- Up & Running OSD or OCP cluster
- [External Secrets Operator](../external-secrets-operator/)
- Splunk HEC token stored in the configured secret backend and referenced by ESO
