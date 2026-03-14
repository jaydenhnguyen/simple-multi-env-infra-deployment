output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.this.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.this.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.this.private_ip
}
