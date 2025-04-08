# OpenShift Cluster Upgrade - Helm Chart

## Pre-requisites:
- [Upgrade an Azure Red Hat OpenShift cluster](https://learn.microsoft.com/en-us/azure/openshift/howto-upgrade)
- [UpgradeConfig CR API specs](https://github.com/openshift/managed-upgrade-operator/blob/master/deploy/crds/upgrade.managed.openshift.io_upgradeconfigs.yaml)


## Procedure

1. Signin to the Cluster

2. Get the cluster upgrade desired `channel` and `version`

    ```sh
    oc get clusterversion -o yaml
    ```

    In this output:

    - The channel is stable-4.9, which is the current channel for upgrades.
    - The availableUpdates section lists the upcoming versions in that channel.
    - The history section shows the upgrade history for your cluster.
  
    If you want to see which upgrade channels are available for your cluster, you can also query the OpenShift release operator resources:

      ```sh
      oc get upgradeconfigs -n openshift-upgrade-operator
      ```
3. Get the desired cluster upgrade start datetime. 
   
   The date time string must be in Zulu format.
   
   ```sh
   date -u +"%Y-%m-%dT%H:%M:%SZ"
   ```
4. Collect the values noted above and update the `values.cluster-name.yaml` file.

    ```yaml
    clusterType: "ARO" # Possible Values: "OSD", "ROSA", "ARO"
    upgradeStartTime: "2024-12-18T00:00:00Z" # Command: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
    nodeDrainTimeout: 60 # in seconds
    desired: # Run `oc get clusterversion -o yaml` to get the supported channels and versions
      channel: "stable-4.15"
      version: "4.15.27"
    ```

5. Commit the helm chart to Git, install the chart

# OpenShift Cluster Upgrade - OpenShift Client

To upgrade the cluster using the command line option, use the `oc adm upgrade` command.

1. View the update status and available cluster updates

    ```sh
    oc adm upgrade
    # On ARO
    az aro get-versions --location=eastus
    ```

2. Update to the latest version

    ```sh
    oc adm upgrade --to-latest=true
    ```

3. Upgrade to a specific version

    ```sh
    oc adm upgrade --to=VERSION [flags] [options]
    ```
