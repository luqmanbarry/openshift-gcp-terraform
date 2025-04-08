# GitLab Runners Helm Chart

This helm chart deploys GitLab runners. Additionally, it deploys one or more `BuildConfig` CRs to build the custom images used as container images by the job execution pods.

As an example, 4 `BuildConfig` CRs are added.

- [openshift-cicd-tools](./templates/2-openshift-cicd-tools-image-bc.yaml): Primarily used for Terraform + Azure automation. It contains tools such as `openshift-client, kubectl, azure-cli, Terraform, Kustomize, helm, jq, python3.12, pip3.12, pipx`.
- [python-cicd-tools](./templates/2-python-cicd-tools-image-bc.yaml): Mainly used for compiling and packaging python3 apps. It contains tools such as `openshift-client, kubectl, azure-cli, helm, jq, python3.12, pip3.12, pipx`.
- [java-cicd-tools](./templates/2-java-cicd-tools-image-bc.yaml): Used for compiling and packaging Java apps. It contains tools such as `openshift-client, azure-cli, helm, jq, Java8, Java17, Java21`.
- [nodejs-cicd-tools](./templates/2-nodejs-cicd-tools-image-bc.yaml): Used for compiling and packaging NodeJS apps. It contains tools such as `openshift-client, azure-cli, helm, jq, NodeJS, NPM`.


The pattern is to add a `BuildConfig` CR for each additional `Runner` CR. Or modify an existing one to add more software packages to the build image.

## Pre-requisites

- Up & Running ARO cluster
- [External Secrets Operator](../external-secrets-operator/)
- GitLab Runner token(s) stored in Azure KeyVault. One distinct token for each runner.
  
## Inputs

Required inputs are defined in the [values.yaml](./values.yaml) file of the helm chart.

> [!IMPORTANT]
> You need a distinct registration token for each additional runner you want to add in GitLab.

The recommended pattern is to keep all common (defaults) parameters set in the `values.yaml` and overwrite params that change per cluster in the `values.<cluster-name>.yaml` file.