variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "gwangsan"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "awscli_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
  default     = "gwangsan.io.kr"
}

variable "certificate_arn" {
  description = "Existing ACM certificate ARN (optional)"
  type        = string
  default     = null
}

variable "enable_http" {
  description = "Enable HTTP listener on ALB"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS listener on ALB"
  type        = bool
  default     = true
}
