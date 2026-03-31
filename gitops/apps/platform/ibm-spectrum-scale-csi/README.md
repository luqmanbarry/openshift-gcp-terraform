# IBM Spectrum Scale CSI

This chart gives you a starting point for IBM Spectrum Scale CSI.

It can do two jobs:

- create a `CSIScaleOperator` custom resource
- create one or more `StorageClass` objects

Safe defaults:

- the driver custom resource is off
- no storage classes are created by default

Important note:

- IBM says the CSI operator needs cluster admin work and environment-specific setup
- use this chart after you are ready with your IBM Spectrum Scale cluster details

Good first step:

1. review IBM prerequisites
2. fill in the `CSIScaleOperator` spec for your environment
3. add storage classes only after the driver is healthy

Sources:

- IBM documents the `CSIScaleOperator` custom resource for driver setup
- IBM also documents OLM and CLI based install paths for OpenShift

Docs:

- https://www.ibm.com/docs/en/spectrum-scale-csi?topic=sscsidc-operator-8
- https://www.ibm.com/docs/en/spectrum-scale-csi?topic=i-installing-spectrum-scale-container-storage-interface-driver-using-operator-lifecycle-manager

Secrets:

- Keep any Spectrum Scale credentials in Google Secret Manager or another approved backend and sync them via ESO. Refer to the ESO secret name from your values files instead of committing raw credentials.
