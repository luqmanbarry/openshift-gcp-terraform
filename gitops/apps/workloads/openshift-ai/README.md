# OpenShift AI

This chart installs Red Hat OpenShift AI Self-Managed.

It does these jobs:

- installs the `rhods-operator`
- creates `DSCInitialization` and `DataScienceCluster` resources
- enables hardware profiles in the dashboard
- keeps Kueue integration set to `Unmanaged`

This module works best with dedicated worker pools for AI workloads, for example:

- `workload.platform/ai=true`

Default placement behavior is simple:

- if you do not provide AI-specific scheduling manifests, OpenShift AI workloads use the default worker pool
- if you want AI workloads on dedicated worker pools, add labels such as `workload.platform/ai=true` and supply matching manifests through `hardwareProfiles`

The `hardwareProfiles` value is a raw-manifest extension point for version-specific `HardwareProfile` or related scheduling resources. This keeps the chart flexible across OpenShift AI versions.
