output "mariadb_instance_id" {
  description = "MariaDB instance ID"
  value       = aws_instance.mariadb.id
}

output "mariadb_private_ip" {
  description = "MariaDB private IP"
  value       = aws_instance.mariadb.private_ip
}

output "redis_instance_id" {
  description = "Redis instance ID"
  value       = aws_instance.redis.id
}

output "redis_private_ip" {
  description = "Redis private IP"
  value       = aws_instance.redis.private_ip
}
