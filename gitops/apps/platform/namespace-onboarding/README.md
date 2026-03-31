# Namespace Onboarding

This chart creates namespaces and common guardrails for app teams.

It can also onboard teams into one shared Argo CD instance.

What it can create:

- `Project`
- optional `ResourceQuota`
- optional `LimitRange`
- optional namespace `RoleBinding` resources
- optional default `NetworkPolicy` resources
- optional `Template` for OpenShift self-service project requests
- optional shared tenant `ArgoCD` instance
- optional one `AppProject` per tenant
- optional namespace RBAC for Argo CD `Application` objects
- optional namespace RBAC for `ApplicationSet` objects

This chart is intended for tenant and workload onboarding, not cluster-scoped RBAC. Use `groups-rbac` for cluster-wide role bindings.
