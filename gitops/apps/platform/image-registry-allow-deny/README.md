# Image Registry Allow Deny

This chart updates the cluster image policy so you can allow only approved registries and images.

It can also install trusted CA certificates for private registries.

Safe defaults:

- no CA bundle copy job runs unless you explicitly enable it
- the schedule is daily rather than every five minutes
- private registry CA input is empty by default

Enable the mutating CronJob only after reviewing the effect on `openshift-config`.
