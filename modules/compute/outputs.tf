output "asg_id" {
  description = "Auto Scaling Group ID"
  value       = aws_autoscaling_group.main.id
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.main.name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Latest version of launch template"
  value       = aws_launch_template.main.latest_version
}
