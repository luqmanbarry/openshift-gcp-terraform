locals {

  cert_application_name               = format("%s-cert-manager-operator", var.cluster_name)
  cert_operator_name                  = "openshift-cert-manager-operator"
  cert_operator_ns                    = "cert-manager-operator"
  cert_ocp_gen_api_secret_name        = "openshift-api-certificate"
  cert_ocp_gen_ingress_secret_name    = "openshift-ingress-certificate"
  cert_manager_cluster_issuer_cr_name = format("%s-letsencrypt", local.cert_operator_name)

  derived_tags = {
    "department"      = var.department
    "environment"     = var.platform_environment
    "cost_center"     = var.cost_center
  }

  resource_tags = merge(
    local.derived_tags, var.default_tags
  )
}