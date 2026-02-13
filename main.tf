terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.awscli_profile
}

# Data Sources
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "asg_user_data" {
  template = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo usermod -aG docker ubuntu
              sudo newgrp docker
            EOF
}

data "template_file" "mariadb_user_data" {
  template = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y mariadb-server
              sudo systemctl enable mariadb
              sudo systemctl start mariadb
            EOF
}

data "template_file" "redis_user_data" {
  template = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y redis-server
              sudo systemctl enable redis-server
              sudo systemctl start redis-server
            EOF
}

# Network Module
module "network" {
  source = "./modules/network"

  vpc_name           = "${var.prefix}-vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}c"]
  public_subnets     = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets    = ["10.0.2.0/24", "10.0.3.0/24"]
  intra_subnets      = ["10.0.4.0/24", "10.0.5.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = local.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"

  prefix = var.prefix
  vpc_id = module.network.vpc_id

  tags = local.common_tags

  depends_on = [module.network]
}

# Bastion Module
module "bastion" {
  source = "./modules/bastion"

  prefix            = var.prefix
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  subnet_id         = module.network.public_subnets[0]
  security_group_id = module.security.bastion_sg_id

  tags = local.common_tags

  depends_on = [module.network, module.security]
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  prefix            = var.prefix
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.public_subnets
  security_group_id = module.security.alb_sg_id

  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
  enable_http     = var.enable_http
  enable_https    = var.enable_https

  tags = local.common_tags

  depends_on = [module.network, module.security]
}

# Compute Module (ASG)
module "compute" {
  source = "./modules/compute"

  prefix            = var.prefix
  ami_id            = data.aws_ami.ubuntu.id
  instance_type     = "t3.medium"
  key_name          = module.bastion.key_name
  user_data         = data.template_file.asg_user_data.rendered
  security_group_id = module.security.app_sg_id
  subnet_ids        = module.network.private_subnets

  target_group_arns = [
    module.alb.spring_target_group_arn,
    module.alb.nestjs_target_group_arn
  ]

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  tags = local.common_tags

  depends_on = [module.network, module.security, module.alb, module.bastion]
}

# Database Module
module "database" {
  source = "./modules/database"

  prefix                     = var.prefix
  ami_id                     = data.aws_ami.ubuntu.id
  instance_type              = "t3.small"
  mariadb_subnet_id          = module.network.intra_subnets[0]
  redis_subnet_id            = module.network.intra_subnets[1]
  mariadb_security_group_id  = module.security.mariadb_sg_id
  redis_security_group_id    = module.security.redis_sg_id
  mariadb_user_data          = data.template_file.mariadb_user_data.rendered
  redis_user_data            = data.template_file.redis_user_data.rendered

  tags = local.common_tags

  depends_on = [module.network, module.security]
}

# Local Variables
locals {
  common_tags = {
    Project     = var.prefix
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
