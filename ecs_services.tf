resource "aws_ecs_service" "airflow" {
  name            = "airflow"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.airflow.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.airflow.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.airflow.arn
    container_name   = "airflow"
    container_port   = var.airflow_ui_port
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_ecs_service" "mlflow" {
  name            = "mlflow"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mlflow.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups  = [aws_security_group.mlflow.id, aws_security_group.ephemeral.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mlflow_tg.arn
    container_name   = "mlflow"
    container_port   = var.mlflow_port
  }

  depends_on = [aws_lb_listener.mlflow_listener]
}
