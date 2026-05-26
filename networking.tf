resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "main-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags                    = { Name = "public-subnet-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"
  tags                    = { Name = "public-subnet-b" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-gateway" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "airflow" {
  name   = "airflow-sg"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "airflow" }
}

resource "aws_vpc_security_group_ingress_rule" "airflow_ui" {
  security_group_id            = aws_security_group.airflow.id
  from_port                    = var.airflow_ui_port
  to_port                      = var.airflow_ui_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "airflow_log" {
  security_group_id            = aws_security_group.airflow.id
  from_port                    = var.airflow_log_port
  to_port                      = var.airflow_log_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "airflow" {
  security_group_id = aws_security_group.airflow.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "mlflow" {
  name   = "mlflow-sg"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "mlflow" }
}

resource "aws_vpc_security_group_ingress_rule" "mlflow" {
  security_group_id            = aws_security_group.mlflow.id
  from_port                    = var.mlflow_port
  to_port                      = var.mlflow_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id # only ALB can reach MLflow
}

resource "aws_vpc_security_group_egress_rule" "mlflow" {
  security_group_id = aws_security_group.mlflow.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "ephemeral" {
  name   = "ephemeral-sg"
  vpc_id = aws_vpc.main.id
  tags   = { Name = "ephemeral" }
}

resource "aws_vpc_security_group_egress_rule" "ephemeral" {
  security_group_id = aws_security_group.ephemeral.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
