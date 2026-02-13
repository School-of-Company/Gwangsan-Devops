variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB (public subnets)"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "Existing ACM certificate ARN (optional)"
  type        = string
  default     = null
}

variable "enable_http" {
  description = "Enable HTTP listener"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
