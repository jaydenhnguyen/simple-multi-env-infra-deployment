output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.this.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.this.public_ip
}

output "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  value       = aws_security_group.this.id
}