# OpenShift Pipelines Operator Bootstrap

Installs the OpenShift Pipelines operator.

Use this module when you want GitOps to create the operator `OperatorGroup` and `Subscription`.

The default OLM channel is `latest`.

The default install plan approval is `Manual`.

Keep it disabled until your cluster team has approved the operator for that cluster.

Production note:

- `latest` can move quickly. Review the channel against your OpenShift and OSD on GCP support policy before enabling it.
