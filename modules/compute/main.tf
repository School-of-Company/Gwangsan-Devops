# IAM Role for ASG Instances
resource "aws_iam_role" "asg_instance" {
  name = "${var.prefix}-asg-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.asg_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.asg_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "asg_instance" {
  name = "${var.prefix}-asg-instance-profile"
  role = aws_iam_role.asg_instance.name

  tags = var.tags
}

# Launch Template
resource "aws_launch_template" "main" {
  name          = "${var.prefix}-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(var.user_data)

  iam_instance_profile {
    name = aws_iam_instance_profile.asg_instance.name
  }

  network_interfaces {
    associate_public_ip_address = false
    device_index                = 0
    security_groups             = [var.security_group_id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = "${var.prefix}-app-instance"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-launch-template"
  })
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "${var.prefix}-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "${var.prefix}-app"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
