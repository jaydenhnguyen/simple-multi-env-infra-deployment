variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "state_bucket" {
  description = "Name of the S3 bucket used to store Terraform state"
  type        = string
}

variable "nonprod_vpc_cidr" {
  description = "CIDR block of the nonprod VPC"
  type        = string
}

variable "prod_vpc_cidr" {
  description = "CIDR block of the prod VPC"
  type        = string
}
