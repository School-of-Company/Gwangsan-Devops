variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "user_data" {
  description = "User data script"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ASG (private subnets)"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
