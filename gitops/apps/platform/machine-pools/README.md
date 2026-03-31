# machine-pools

Use this app only if your platform team has approved GitOps management of `MachineSet` objects on OSD on GCP.

This chart renders:

- `MachineSet` objects
- `MachineAutoscaler` objects

For most clusters in this repo, worker pools should stay in Terraform. This chart is only for teams that manage extra machine API objects in the cluster after it is created.

How to use it:

1. Get an existing machine set from the cluster with `oc get machineset -n openshift-machine-api -o yaml`.
2. Copy one worker `MachineSet` into `clusters/<group-path>/<cluster>/values/machine-pools.yaml`.
3. Change the name, labels, replicas, VM size, and zone for the new pool.
4. Add a `MachineAutoscaler` entry if you want autoscaling for that machine set.
5. Enable this app in `gitops.yaml`.

Important note:

- copy a real worker `MachineSet` from the cluster first, then edit it
- keep the image, identity, network, and secret fields from the real cluster unless you know they need to change
