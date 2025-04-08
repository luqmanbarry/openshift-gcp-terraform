variable "platform_environment" {
  type = string
  description = "The OCP cluster environment"
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-south1"
  description = "The region where the OSD cluster is created"
}

variable "default_zone" {
  type        = string
  default = "us-south1-a"
  description = "The GCP zone"
}

variable "department" {
  type        = string
  description = "The Organization folder. This could be seen as a department/business_unit"
  default = "changeme"
}

variable "cost_center" {
  type = string
  default = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "cluster_name" {
  type        = string
  description = "The name of the OCP cluster to create"
  default = "osd-classic-001"
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
  }
  description = "Default Azure resource tags. Should be set at the admin level."
}

variable "private_cluster" {
  type = bool
  description = "Make the ARO cluster public (internet access) or private"
}

variable "default_kubeconfig_filename" {
  type = string
  default = "~/.kube/config"
}

variable "managed_cluster_kubeconfig_filename" {
  type = string
  default = "~/.managed_cluster_kube/config"
}

variable "cluster_details_secret_name" {
  type = string
  default = "openshift-OCP_ENV-CLUSTER_NAME-cluster-details"
  description = "The name of the secret that will hold the cluster admin details"
}

variable "custom_dns_domain_prefix" {
  type = string
  description = "The custoom DNS domain prefix specific to the cluster"
  default = "luqman"
}

variable "cluster_project" {
  type        = string
  description = "The Cluster GCP project in which to create the cluster"
  default = "gcp-classic-001"
}

variable "dns_ttl" {
  type = number
  description = "Default domain DNS TTL"
  default = 3600
}

variable "custom_dns_domain_name" {
  type = string
  description = "The custoom DNS domain specific to the cluster"
  default = "aro-classic1.dev.estus.rnd.openshift.sama-wat.com"
}

variable "base_dns_zone_project" {
  type = string
  description = "The project of the base DNS zone name; the parent DNS zone name."
  default = ""
}

variable "use_auto_generated_domain" {
  type = bool
  default = true
  description = "Do you want to provide your own domain? true or false"
}

variable "cert_issuer_email" {
  type = string
  default = "cluster-admin@example.com"
}

variable "cert_issuer_server" {
  type = string
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "tls_certificates_ttl_seconds" {
  type = string
  description = "The TLS/SSL certificates duration."
  default = "31536000s"
}

variable "dns_tls_certificates_subject" {
  type = object({
    country = string
    locality = string
    organizationalUnit = string
    organization = string
    province = string
    postalCode = string
    streetAddresse = string
  })

  default = {
    country = "United States"
    locality = "Raleigh"
    organizationalUnit = "Research & Development (RND)"
    organization = "Example Inc"
    province = "North Carolina"
    postalCode = "27601"
    streetAddresse = "100 East Davie Street"
  }
}
