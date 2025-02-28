variable "cluster_name" {
  default     = "rosa-sts-001"
  type        = string
  description = "The name of the ROSA cluster to create"
}

variable "organization" {
  type        = string
  description = "The  business unit that owns the cluster."
  default = "sales"
}

variable "subscription_id" {
  type = string
  description = "The subscription ID of the business unit org"
}

variable "git_username" {
  type          = string
  description   = "The GitHub username"
  default = "luqmanbarry"
}

variable "git_token" {
  type          = string
  description   = "The GitHub Personal Access Token (PAT)"
  default = "my-personal-access-token"
}

variable "git_base_url" {
  type          = string
  description   = "This is the target GitHub base API endpoint. The value must end with a slash."
  default = "https://corporate.github.com/"
}

variable "git_org" {
  type = string
  description = "This is the target GitHub organization or individual user account to manage"
  default = "platform-ops"
}

variable "git_repository_name" {
  type = string
  description = "The GitHub Repository name"
  default = "rosa-sts-terraform"  
}

variable "git_branch" {
  type = string
  description = "The base branch" 
  default = "main" 
}

variable "git_ci_job_number" {
  type = string
  default = "123"
}

variable "git_ci_job_identifier" {
  type = string
  description = "The CI job identifier - Job url"
  default = "https://cicd.corporate.com/path/to/job/job-123"  
}

variable "git_commit_email" {
  type = string
  description = "The email of the commit author."
  default = "platform-ops@corporate.com"
}

variable "git_action_taken" {
  type            = string
  description     = "The action the CI Job took: options: ROSAClusterCreate, ROSAClusterUpdate,,,etc"
  default         = "ROSAClusterCreate"
}

variable "platform_environment" {
  type = string
  description = "The ROSA cluster environment"
  default = "dev"
}