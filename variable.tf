variable "cluster_name" {
    default = "demo_cluster"
}

variable "env" {
    default = "dev"
}

variable "cidr" {
  description = "the CIDR block for the vpc"
  type        = string
  default     = "10.101.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}