# Network Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.network.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.network.private_subnets
}

output "intra_subnets" {
  description = "Intra (protected) subnet IDs"
  value       = module.network.intra_subnets
}

# Security Outputs
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security.alb_sg_id
}

output "app_security_group_id" {
  description = "Application security group ID"
  value       = module.security.app_sg_id
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = module.security.bastion_sg_id
}

output "mariadb_security_group_id" {
  description = "MariaDB security group ID"
  value       = module.security.mariadb_sg_id
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = module.security.redis_sg_id
}

# Bastion Outputs
output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.bastion.public_ip
}

output "bastion_private_key_path" {
  description = "Path to bastion private key file"
  value       = module.bastion.private_key_path
  sensitive   = true
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "spring_target_group_arn" {
  description = "Spring application target group ARN"
  value       = module.alb.spring_target_group_arn
}

output "nestjs_target_group_arn" {
  description = "NestJS application target group ARN"
  value       = module.alb.nestjs_target_group_arn
}

# Compute Outputs
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.asg_name
}

# Database Outputs
output "mariadb_private_ip" {
  description = "MariaDB private IP address"
  value       = module.database.mariadb_private_ip
}

output "redis_private_ip" {
  description = "Redis private IP address"
  value       = module.database.redis_private_ip
}

# AMI Output
output "ubuntu_ami_id" {
  description = "Ubuntu AMI ID used"
  value       = data.aws_ami.ubuntu.id
}
