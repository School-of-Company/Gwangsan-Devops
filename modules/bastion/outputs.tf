output "instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "public_ip" {
  description = "Bastion public IP"
  value       = aws_eip.bastion.public_ip
}

output "key_name" {
  description = "Bastion key pair name"
  value       = aws_key_pair.bastion.key_name
}

output "private_key_path" {
  description = "Path to private key file"
  value       = local_file.bastion_private_key.filename
}
