output "vpc_id" {
  description = "VPC ID of the nonprod environment"
  value       = module.network.vpc_id
}

output "private_route_table_id" {
  description = "Private subnet IDs in nonprod"
  value       = module.network.public_route_table_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = module.bastion.bastion_private_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion from Cloud9"
  value       = "ssh -A -i ~/environment/simple-multi-env-infra-deployment/acs730-key ec2-user@${module.bastion.bastion_public_ip}"
}

output "private_vm_private_ips" {
  description = "Private IP addresses of the nonprod VMs"
  value       = module.ec2.private_vm_private_ips
}

output "ssh_to_vm1_from_bastion" {
  description = "SSH command from bastion to VM1"
  value       = "ssh ec2-user@${module.ec2.private_vm_private_ips[0]}"
}

output "ssh_to_vm2_from_bastion" {
  description = "SSH command from bastion to VM2"
  value       = "ssh ec2-user@${module.ec2.private_vm_private_ips[1]}"
}

output "curl_vm1" {
  description = "Test Apache on VM1"
  value       = "curl http://${module.ec2.private_vm_private_ips[0]}"
}

output "curl_vm2" {
  description = "Test Apache on VM2"
  value       = "curl http://${module.ec2.private_vm_private_ips[1]}"
}