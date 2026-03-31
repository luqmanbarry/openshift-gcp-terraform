# File Integrity Operator Bootstrap

Installs the File Integrity Operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

The default OLM channel is `stable`.

The default install plan approval is `Manual`.

Keep it disabled until your cluster team has approved the operator for that cluster.
