# Bastion Key Pair
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion" {
  key_name   = "${var.prefix}-bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh

  tags = var.tags
}

resource "local_file" "bastion_private_key" {
  content         = tls_private_key.bastion.private_key_pem
  filename        = "${path.root}/${var.prefix}-bastion-key.pem"
  file_permission = "0400"
}

# Bastion IAM Role
resource "aws_iam_role" "bastion" {
  name = "${var.prefix}-bastion-role"

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

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "bastion_power_user" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.prefix}-bastion-profile"
  role = aws_iam_role.bastion.name

  tags = var.tags
}

# Bastion Instance
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.bastion.key_name
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids = [var.security_group_id]

  tags = merge(var.tags, {
    Name = "${var.prefix}-bastion"
  })
}

# Elastic IP
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.prefix}-bastion-eip"
  })
}
