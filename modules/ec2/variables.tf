variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name such as nonprod or prod"
  type        = string
  default     = "nonprod"
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security group ID of bastion host allowed to SSH into private VMs"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for private instances like VM1 and VM2"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR block allowed to SSH into bastion host"
  type        = string
}

variable "owner_name" {
  description = "Your name to print on the Apache page"
  type        = string
}