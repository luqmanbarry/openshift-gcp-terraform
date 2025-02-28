
variable "company_name" {
  type = string
  default = "sama-wat-inc"
}


variable "department" {
  type        = string
  description = "The Organization folder. This could be seen as a department/business_unit"
  default = "changeme"
}

variable "resource_name_suffix" {
  type = string
  default = "platformops"
}

variable "tfstate_project" {
  type = string
  default = "osd-gcp-tfstate"
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

variable "tfstate_storage_bucket_name" {
  type = string
  description = "The tfstate storage bucket name. It must be globally unique"
  default = "derived"
}

variable "cluster_name" {
  type = string
  default = "aro-classic-101"
}

variable "platform_environment" {
  type = string
  default = "dev"
}

variable "cost_center" {
  type = string
  default = "47007"
}

variable "default_tags" {
  default = {
    Terraform   = "true"
  }
  description = "Additional Azure resource tags"
  type        = map(string)
}