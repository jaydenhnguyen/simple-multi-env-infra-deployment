output "private_vm_instance_ids" {
  description = "Instance IDs of the private VMs"
  value       = aws_instance.private_vm[*].id
}

output "private_vm_private_ips" {
  description = "Private IP addresses of the private VMs"
  value       = aws_instance.private_vm[*].private_ip
}

output "private_vm_security_group_id" {
  description = "Security group ID of the private VMs"
  value       = aws_security_group.private_sg.id
}