variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for database instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for database instances"
  type        = string
  default     = "t3.small"
}

variable "mariadb_subnet_id" {
  description = "Subnet ID for MariaDB (intra subnet)"
  type        = string
}

variable "redis_subnet_id" {
  description = "Subnet ID for Redis (intra subnet)"
  type        = string
}

variable "mariadb_security_group_id" {
  description = "Security group ID for MariaDB"
  type        = string
}

variable "redis_security_group_id" {
  description = "Security group ID for Redis"
  type        = string
}

variable "mariadb_user_data" {
  description = "User data script for MariaDB"
  type        = string
}

variable "redis_user_data" {
  description = "User data script for Redis"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
