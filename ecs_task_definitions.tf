

resource "aws_ecs_task_definition" "airflow" {
  family                   = "airflow"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.airflow_cpu
  memory                   = var.airflow_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  # task_role_arn            = aws_iam_role.airflow_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "airflow"
      image     = "${aws_ecr_repository.airflow.repository_url}:latest"
      essential = true

      environment = [
        {
          name  = "ECS_TARGET_SUBNETS"
          value = join(",", [aws_subnet.public_a.id, aws_subnet.public_b.id])
        },
        {
          name  = "ECS_TARGET_SECURITY_GROUPS"
          value = aws_security_group.ephemeral.id
        }
      ]
      portMappings = [
        { containerPort = var.airflow_ui_port },
        { containerPort = var.airflow_log_port }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/airflow"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "model_training" {
  family                   = "model_training"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.model_training_cpu
  memory                   = var.model_training_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  container_definitions = jsonencode([
    {
      name      = "model_training"
      image     = "${aws_ecr_repository.model_training.repository_url}:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/model_training"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "feature_engineering" {
  family                   = "feature_engineering"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.feature_engineering_cpu
  memory                   = var.feature_engineering_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  container_definitions = jsonencode([
    {
      name      = "feature_engineering"
      image     = "${aws_ecr_repository.feature_engineering.repository_url}:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/feature_engineering"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "mlflow" {
  family                   = "mlflow"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.mlflow_cpu
  memory                   = var.mlflow_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  container_definitions = jsonencode([
    {
      name      = "mlflow"
      image     = "${aws_ecr_repository.mlflow.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = var.mlflow_port } # was missing entirely
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/mlflow"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
