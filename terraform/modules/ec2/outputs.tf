output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "instance_ids" {
  description = "Application instance IDs"
  value       = aws_instance.app[*].id
}

output "instance_private_ips" {
  description = "Application instance private IPs"
  value       = aws_instance.app[*].private_ip
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion.id
}

output "app_security_group_id" {
  description = "App security group ID"
  value       = aws_security_group.app.id
}
