# IAM Role for Database Instances
resource "aws_iam_role" "db_instance" {
  name = "${var.prefix}-db-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "db_ssm" {
  role       = aws_iam_role.db_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "db_cloudwatch" {
  role       = aws_iam_role.db_instance.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "db_instance" {
  name = "${var.prefix}-db-instance-profile"
  role = aws_iam_role.db_instance.name

  tags = var.tags
}

# MariaDB Instance
resource "aws_instance" "mariadb" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.mariadb_subnet_id
  iam_instance_profile = aws_iam_instance_profile.db_instance.id
  user_data            = var.mariadb_user_data

  vpc_security_group_ids = [var.mariadb_security_group_id]

  tags = merge(var.tags, {
    Name = "${var.prefix}-mariadb"
  })
}

# Redis Instance
resource "aws_instance" "redis" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.redis_subnet_id
  iam_instance_profile = aws_iam_instance_profile.db_instance.id
  user_data            = var.redis_user_data

  vpc_security_group_ids = [var.redis_security_group_id]

  tags = merge(var.tags, {
    Name = "${var.prefix}-redis"
  })
}
