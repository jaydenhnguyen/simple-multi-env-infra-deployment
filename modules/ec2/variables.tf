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

variable "private_subnet_ids" {
  description = "List of private subnet IDs for private instances like VM1 and VM2"
  type        = list(string)
}

variable "bastion_private_ip" {
  description = "Security group ID of bastion host allowed to SSH into private VMs"
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

variable "user_data_list" {
  type    = list(any)
  default = []
}
