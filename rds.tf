resource "aws_security_group" "rds_mlflow" {
  name   = "rds-mlflow-sg"
  vpc_id = aws_vpc.main.id # Assumes your VPC resource is named aws_vpc.main

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ephemeral.id]
  }

  tags = { Name = "rds-mlflow-sg" }
}

resource "aws_db_subnet_group" "mlflow_db_subnet" {
  name       = "mlflow-db-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_db_instance" "mlflow_db" {
  identifier        = "mlflow-backend-db"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "mlflowdb"
  username = "mlflow_user"
  password = "ChangeThisSuperSecretPassword123" # Must be at least 8 chars

  db_subnet_group_name   = aws_db_subnet_group.mlflow_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_mlflow.id]

  publicly_accessible = false
  skip_final_snapshot = true
}
