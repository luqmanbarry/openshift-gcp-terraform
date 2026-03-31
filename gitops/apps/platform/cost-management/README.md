# Cost Management

This chart installs the Cost Management operator and can create the `CostManagement` custom resource.

Keep it disabled until you are ready to subscribe the operator and create the app resource.

Safe defaults:

- operator install is off
- app creation is off
- install plan approval is `Manual`

## How To Enable

1. Make sure your organization has the right entitlement for Cost Management.
2. Update `clusters/<group-path>/<cluster>/values/cost-management.yaml`.
3. Set `install.enabled: true` to install the operator.
4. Set `app.enabled: true` when you are ready to create the `CostManagement` custom resource.
5. Enable the app in `gitops.yaml`.

## Main Inputs

- `install.namespace`: namespace for the operator.
- `install.subscriptionName`, `install.packageName`, `install.channel`: operator subscription settings.
- `app.namespace`: namespace for the `CostManagement` custom resource.
- `app.config`: app-specific settings.

## Prerequisites

- Red Hat Cost Management entitlement.
- Access to the required OperatorHub catalog source.
- Google Secret Manager and ESO for any credentials you do not want in Git.
