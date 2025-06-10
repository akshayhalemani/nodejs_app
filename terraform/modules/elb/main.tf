# Security group
resource "aws_security_group" "alb_sg" {
  vpc_id = var.app_vpc_id
  ingress { 
    from_port = 80; 
    to_port = 80; 
    protocol = "http"; 
    cidr_blocks = ["0.0.0.0/0"] }
  ingress { 
    from_port = 443; 
    to_port = 443; 
    protocol = "https"; 
    cidr_blocks = ["0.0.0.0/0"] }

  egress { 
    from_port = 0; 
    to_port = 0; 
    protocol = "-1"; 
    cidr_blocks = ["10.10.0.0/16"] }
}

# ALB
resource "aws_lb" "alb" {
  name                = "${var.name}-alb"
  internal            = false
  load_balancer_type  = "application"
  subnets             = var.subnet_ids
  security_groups     = [aws_security_group.alb_sg.id]
}

# Target group
resource "aws_lb_target_group" "alb_tg" {
  name     = "${var.name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.app_vpc_id
  health_check { 
    path = "/app"; 
    interval = 30; 
    healthy_threshold = 2; 
    unhealthy_threshold = 2 
    }
    tags = {
    Name = "${var.name}-tg"
  }
}

# Listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
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

# Redirection Listerner to HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Default response: Not found"
      status_code  = "404"
    }
  }
}

# Listener rule

resource "aws_lb_listener_rule" "app_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  condition {
    host_header {
      values = [var.app_domain]
    }
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "${var.name}-cert"
  }
}

