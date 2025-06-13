variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "hcp_client_id" {
  description = "HCP service principal client ID"
  type        = string
  sensitive   = true
}

variable "hcp_client_secret" {
  description = "HCP service principal client secret"
  type        = string
  sensitive   = true
}

variable "hcp_project_id" {
  description = "HCP project ID"
  type        = string
}

variable "hcp_hvn_id" {
  description = "HCP HVN ID"
  type        = string
  default     = "hvn"
}

variable "hcp_cidr_block" {
  description = "CIDR block for the HCP HVN"
  type        = string
}

variable "consul_admin_token" {
  description = "Consul admin token for the cluster"
  type        = string
  sensitive   = true
}

variable "consul_ent_license" {
  description = "Consul Enterprise license file content"
  type        = string
  sensitive   = true
}

variable "cloud_provider" {
  description = "Cloud provider for HCP HVN"
  type        = string
}

variable "region" {
  description = "Region for the HVN"
  type        = string
}