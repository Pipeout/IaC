# ─────────────────────────────────────────
# Security Group for the ALB
# ─────────────────────────────────────────
resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "alb" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0" # restrict to your IP for extra safety e.g. "YOUR_IP/32"
}

resource "aws_vpc_security_group_egress_rule" "alb" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ─────────────────────────────────────────
# ALB
# ─────────────────────────────────────────
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id] # ALB needs 2 AZs

  tags = { Name = "main-alb" }
}

# ─────────────────────────────────────────
# Target Groups
# ─────────────────────────────────────────
resource "aws_lb_target_group" "airflow" {
  name        = "airflow-tg"
  port        = var.airflow_ui_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # required for Fargate

  health_check {
    path                = "/health"
    port                = var.airflow_ui_port
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = { Name = "airflow-tg" }
}

resource "aws_lb_target_group" "mlflow" {
  name        = "mlflow-tg"
  port        = var.mlflow_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # required for Fargate

  health_check {
    path                = "/health"
    port                = var.mlflow_port
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = { Name = "mlflow-tg" }
}

# ─────────────────────────────────────────
# Listener (port 80) + routing rules
# ─────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Default action: return 404 if no rule matches
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

# Route /airflow* → Airflow target group
resource "aws_lb_listener_rule" "airflow" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.airflow.arn
  }

  condition {
    path_pattern {
      values = ["/airflow*", "/"]
    }
  }
}

# Route /mlflow* → MLflow target group
resource "aws_lb_listener_rule" "mlflow" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mlflow.arn
  }

  condition {
    path_pattern {
      values = ["/mlflow*"]
    }
  }
}

# ─────────────────────────────────────────
# Outputs — your URLs after terraform apply
# ─────────────────────────────────────────
output "airflow_url" {
  value = "http://${aws_lb.main.dns_name}/airflow"
}

output "mlflow_url" {
  value = "http://${aws_lb.main.dns_name}/mlflow"
}
