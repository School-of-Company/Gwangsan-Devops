variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for bastion instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for bastion"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID for bastion (public subnet)"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for bastion"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
