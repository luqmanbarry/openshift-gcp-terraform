# OpenShift Data Foundation Operator Bootstrap

Installs the OpenShift Data Foundation operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

The default OLM channel is `stable-4.18`.

The default install plan approval is `Manual`.

Keep it disabled until you have an approved storage design for the cluster.
