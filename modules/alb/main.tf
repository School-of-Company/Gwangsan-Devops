# ACM Certificate
resource "aws_acm_certificate" "main" {
  count = var.domain_name != null ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.prefix}-alb"
  })
}

# Target Groups
resource "aws_lb_target_group" "spring" {
  name        = "${var.prefix}-spring-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-spring-tg"
  })
}

resource "aws_lb_target_group" "nestjs" {
  name        = "${var.prefix}-nestjs-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    path                = "/api/health/check"
    port                = "8081"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-nestjs-tg"
  })
}

# HTTP Listener (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  count = var.enable_http ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count = var.enable_https && var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate.main[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring.arn
  }
}

# Listener Rules
resource "aws_lb_listener_rule" "nestjs_health" {
  count = var.enable_https && var.certificate_arn != null ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nestjs.arn
  }

  condition {
    path_pattern {
      values = ["/api/health/check"]
    }
  }
}

resource "aws_lb_listener_rule" "nestjs_chat" {
  count = var.enable_https && var.certificate_arn != null ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nestjs.arn
  }

  condition {
    path_pattern {
      values = ["/api/chat"]
    }
  }
}

resource "aws_lb_listener_rule" "nestjs_socket" {
  count = var.enable_https && var.certificate_arn != null ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nestjs.arn
  }

  condition {
    path_pattern {
      values = ["/socket.io/*"]
    }
  }
}

resource "aws_lb_listener_rule" "spring_chat_subpath" {
  count = var.enable_https && var.certificate_arn != null ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring.arn
  }

  condition {
    path_pattern {
      values = ["/api/chat/*"]
    }
  }
}

resource "aws_lb_listener_rule" "spring_api" {
  count = var.enable_https && var.certificate_arn != null ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "spring_default" {
  count = var.enable_https && var.certificate_arn != null ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
