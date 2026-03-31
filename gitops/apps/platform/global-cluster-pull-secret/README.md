# Global Pull Secret

This chart can sync extra registry credentials into the cluster pull secret.

Safe defaults:

- the shared store name defaults to `platform-secrets`
- the extra secret name is empty by default
- the update job is disabled by default
- the schedule is daily rather than every five minutes

Enable the mutating CronJob only after reviewing the effect on your cluster-wide pull secret and confirming the input secret exists.
