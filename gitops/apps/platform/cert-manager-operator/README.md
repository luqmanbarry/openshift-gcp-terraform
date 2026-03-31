# cert-manager-operator

Installs the cert-manager Operator for Red Hat OpenShift.

## Default

- namespace: `cert-manager-operator`
- package: `openshift-cert-manager-operator`
- source: `redhat-operators`
- channel: `stable-v1`
- install plan approval: `Automatic`

## Notes

- This chart installs only the operator lifecycle resources.
- Issuers, ClusterIssuers, and Certificates should live in other GitOps modules.
- The defaults match the current OpenShift 4.20 operator guidance.
- Automatic approval is intentional because `cert-manager-config` depends on the cert-manager CRDs.
