locals {
  klusterlet_crd_yaml = format("/tmp/%s-klusterlet-crd.yaml", var.cluster_name)
  import_file_yaml    = format("/tmp/%s-import.yaml", var.cluster_name)
}
