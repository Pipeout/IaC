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

resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id] # ALB needs 2 AZs

  tags = { Name = "main-alb" }
}

resource "aws_lb_target_group" "airflow" {
  name        = "airflow-tg"
  port        = var.airflow_ui_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = var.airflow_ui_port
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }

  tags = { Name = "airflow-tg" }
}


output "airflow_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "mlflow_url" {
  value = "http://${aws_lb.mlflow_alb.dns_name}"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.airflow.arn
  }
}

resource "aws_security_group" "mlflow_alb_sg" {
  name        = "mlflow-dedicated-alb-sg"
  description = "Allow inbound web traffic to MLflow ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. The Dedicated Application Load Balancer
resource "aws_lb" "mlflow_alb" {
  name               = "mlflow-dedicated-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mlflow_alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_lb_target_group" "mlflow_tg" {
  name        = "mlflow-target-group"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # Required for Fargate

  health_check {
    path                = "/" # MLflow has a native /ping endpoint that returns 200 OK
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 4
  }
}

resource "aws_lb_listener" "mlflow_listener" {
  load_balancer_arn = aws_lb.mlflow_alb.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mlflow_tg.arn
  }
}


# Allow the new dedicated ALB to talk to the MLflow Fargate Container
resource "aws_security_group_rule" "mlflow_alb_to_container" {
  type      = "ingress"
  from_port = 5000
  to_port   = 5000
  protocol  = "tcp"

  # The Security Group attached to the MLflow Fargate Service
  security_group_id = aws_security_group.mlflow.id

  # The Security Group attached to the Dedicated MLflow ALB
  source_security_group_id = aws_security_group.mlflow_alb_sg.id
}
