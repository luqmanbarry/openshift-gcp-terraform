## ACMHUB: Create ManagedCluster CR
resource "kubernetes_manifest" "hub_managedcluster_cr" {
  # depends_on  = [ kubernetes_namespace.hub_namespace_managed_cluster ]
  provider    = kubernetes.acmhub_cluster
  manifest = {
    "apiVersion" = "cluster.open-cluster-management.io/v1"
    "kind"       = "ManagedCluster"
    "metadata" = {
      "name" = var.cluster_name
    }
    "spec" = {
      "hubAcceptsClient" = true
    }
  }
  wait {
    fields = {
      "metadata.creationTimestamp" = ".+"
    }
  }
}

## ACMHUB: Create KlusterletAddonConfig CR
resource "kubernetes_manifest" "hub_klusterletaddonconfig_cr" {
  depends_on  = [ kubernetes_manifest.hub_managedcluster_cr ]
  provider    = kubernetes.acmhub_cluster
  manifest = {
    "apiVersion" = "agent.open-cluster-management.io/v1"
    "kind" = "KlusterletAddonConfig"
    "metadata" = {
      "name" = var.cluster_name
      "namespace" = var.cluster_name
    }
    "spec" = {
      "applicationManager" = {
        "enabled" = true
      }
      "certPolicyController" = {
        "enabled" = true
      }
      "clusterLabels" = {
        "cloud" = "auto-detect"
        "vendor" = "auto-detect"
      }
      "clusterName" = var.cluster_name
      "clusterNamespace" = var.cluster_name
      "iamPolicyController" = {
        "enabled" = true
      }
      "policyController" = {
        "enabled" = true
      }
      "searchCollector" = {
        "enabled" = true
      }
      "version" = "2.0.0"
    }
  }
  wait {
    fields = {
      "metadata.creationTimestamp" = ".+"
    }
  }
}

resource "time_sleep" "wait_for_import_secret" {
  depends_on  = [ kubernetes_manifest.hub_klusterletaddonconfig_cr ]
  create_duration = "30s"
}

## ACMHUB: Obtain the crds.yaml, impoart.yaml that were generated as a result
data "kubernetes_secret" "import_manifests" {
  depends_on  = [ time_sleep.wait_for_import_secret ]
  provider    = kubernetes.acmhub_cluster
  metadata {
    name = format("%s-import", var.cluster_name)
    namespace = var.cluster_name
  }
}

## Local FileSystem: Write the crds.yaml string to a file
resource "local_sensitive_file" "klusterlet_crd_yaml" {
  depends_on  = [ data.kubernetes_secret.import_manifests ]
  content     = try(lookup(data.kubernetes_secret.import_manifests.data, "crds.yaml"), null)
  filename    = local.klusterlet_crd_yaml
}

## Managed Cluster: Apply the crds.yaml file
resource "null_resource" "managed_apply_klusterlet_crd" {
  depends_on  = [ local_sensitive_file.klusterlet_crd_yaml ]

  # Print the crds.yaml file to stdout
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "cat $RESOURCE_FILE"
    environment = {
      RESOURCE_FILE = local.klusterlet_crd_yaml
    }
  }

  # oc apply the resource file
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "oc apply --kubeconfig=$KUBECONFIG -f $RESOURCE_FILE"
    environment = {
      KUBECONFIG    = var.managed_cluster_kubeconfig_filename
      RESOURCE_FILE = local.klusterlet_crd_yaml
    }
  }
  triggers = {
    timestamp = timestamp()
  }
}

## Local FileSystem: Write import.yaml string to a file
resource "local_sensitive_file" "import_crd_yaml" {
  depends_on  = [ null_resource.managed_apply_klusterlet_crd ]
  content     = try(lookup(data.kubernetes_secret.import_manifests.data, "import.yaml"), null)
  filename    = local.import_file_yaml
}

## Managed Cluster: Apply the import.yaml file
resource "null_resource" "managed_apply_import_yaml" {
  depends_on  = [ local_sensitive_file.import_crd_yaml ]

  # Print the import.yaml file to stdout
  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "cat $RESOURCE_FILE"
    environment = {
      RESOURCE_FILE = local.import_file_yaml
    }
  }

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-c" ]
    command = "oc apply --kubeconfig=$KUBECONFIG -f $RESOURCE_FILE"
    environment = {
      KUBECONFIG    = var.managed_cluster_kubeconfig_filename
      RESOURCE_FILE = local.import_file_yaml
    }
  }
  triggers = {
    timestamp = timestamp()
  }
}
