output "alb_sg_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "bastion_sg_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion.id
}

output "app_sg_id" {
  description = "Application security group ID"
  value       = aws_security_group.app.id
}

output "mariadb_sg_id" {
  description = "MariaDB security group ID"
  value       = aws_security_group.mariadb.id
}

output "redis_sg_id" {
  description = "Redis security group ID"
  value       = aws_security_group.redis.id
}
