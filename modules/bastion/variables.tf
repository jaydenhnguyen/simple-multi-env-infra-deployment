variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name such as nonprod or prod"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "List of public subnet IDs for public instances like bastion host"
  type        = string
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

variable "admin_ip" {
  description = "CIDR block allowed to SSH into bastion host"
  type        = string
}