resource "aws_ecs_service" "airflow" {
  name            = "airflow"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_task_definition.airflow.arn
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets          = [aws_subnet.public_a.id]
    security_groups  = [aws_security_group.airflow.id]
    assign_public_ip = true
  }
}


resource "aws_ecs_service" "mlflow" {
  name            = "mlflow"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_task_definition.mlflow.arn
  desired_count   = 1
  launch_type     = "FARGATE"


  network_configuration {
    subnets          = [aws_subnet.public_a.id]
    security_groups  = [aws_security_group.mlflow.id]
    assign_public_ip = true
  }
}
