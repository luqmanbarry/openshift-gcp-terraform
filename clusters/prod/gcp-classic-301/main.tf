module "factory_stack" {
  source = "../../../modules/factory-stack"

  stack = var.stack

  default_kubeconfig_filename         = var.default_kubeconfig_filename
  managed_cluster_kubeconfig_filename = var.managed_cluster_kubeconfig_filename
  acmhub_kubeconfig_filename          = var.acmhub_kubeconfig_filename
}
