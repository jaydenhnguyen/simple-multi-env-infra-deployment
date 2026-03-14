output "prod_vpc_id" {
  description = "VPC ID of the prod environment"
  value       = module.network.vpc_id
}

output "prod_subnet_ids" {
  description = "Private subnet IDs in prod"
  value       = module.network.private_subnet_ids
}

output "prod_instance_ids" {
  description = "Instance IDs of prod VMs"
  value       = module.ec2.private_vm_instance_ids
}

output "prod_private_ips" {
  description = "Private IPs of prod VMs"
  value       = module.ec2.private_vm_private_ips
}

output "private_route_table_id" {
  description = "Private route table ID in prod"
  value       = module.network.private_route_table_id
}

output "ssh_vm1_from_bastion" {
  description = "SSH command to connect to prod VM1 from bastion"
  value       = "ssh ec2-user@${module.ec2.private_vm_private_ips[0]}"
}

output "ssh_vm2_from_bastion" {
  description = "SSH command to connect to prod VM2 from bastion"
  value       = "ssh ec2-user@${module.ec2.private_vm_private_ips[1]}"
}