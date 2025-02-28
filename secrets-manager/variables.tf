variable "platform_environment" {
  type = string
  description = "The ROSA cluster environment"
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
  description = "The location where the ARO cluster is created"
}

variable "department" {
  type        = string
  description = "The Organization folder"
  default = "provided"
}

variable "cost_center" {
  type = string
  default = "1234567"
  description = "The cost center code used for tracking resource consumption"
}

variable "cluster_name" {
  type        = string
  description = "The name of the OSD cluster to create"
  default = "osd-gcp-001"
}

variable "default_tags" {

  type        = map(string)
  default = {
    "AutomationTool" = "Terraform"
  }
  description = "Additional Azure resource tags"
}

variable "private_cluster" {
  type = bool
  description = "Make the ARO cluster public (internet access) or private"
}

variable "secret_manager_name" {
  type = string
  description = "The name of the Secrets Manager instance hosting OpenShift secrets"
  default = "provided"
}

variable "secret_manager_project" {
  type = string
  description = "The project of the Secrets Manager instance hosting OpenShift secrets"
  default = "provided"
}

variable "region" {
  type    = string
  default = "us-south1" # https://googlecloudplatform.github.io/region-picker/
  description = "The region where the OSD cluster is created"
}

variable "default_zone" {
  type        = string
  default = "us-south1-a"
  description = "The GCP zone"
}