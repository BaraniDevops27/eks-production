variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"

  validation {
    condition     = contains(["ap-south-1"], var.region)
    error_message = "Only ap-south-1 region is allowed."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  default = "10.0.3.0/24"
}

variable "private_subnet_1_cidr" {
  default = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  default = "10.0.4.0/24"
}

variable "eks_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.30"
}

variable "node_instance_type" {
  description = "EKS Node Instance Type"
  type        = string
  default     = "t3.medium"
}

variable "node_disk_size" {
  description = "Node disk size"
  type        = number
  default     = 20
}