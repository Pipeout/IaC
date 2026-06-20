

resource "aws_ecs_task_definition" "airflow" {
  family                   = "airflow"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.airflow_cpu
  memory                   = var.airflow_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.airflow_task_role.arn
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
  task_role_arn            = aws_iam_role.model_training_task_role.arn
  container_definitions = jsonencode([
    {
      environment = [


        {
          name  = "MLFLOW_TRACKING_URI",
          value = "http://${aws_lb.mlflow_alb.dns_name}:5000"
        },
        {
          name  = "ECS_TARGET_SUBNETS"
          value = join(",", [aws_subnet.public_a.id, aws_subnet.public_b.id])
        },
        {
          name  = "ECS_TARGET_SECURITY_GROUPS"
          value = aws_security_group.ephemeral.id
        }
      ]
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
  task_role_arn            = aws_iam_role.feature_engineering_task_role.arn
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
  task_role_arn            = aws_iam_role.mlflow_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "mlflow"
      image     = "${aws_ecr_repository.mlflow.repository_url}:latest"
      essential = true
      environment = [
        {
          name = "BACKEND_STORE_URI"
        value = "postgresql://${aws_db_instance.mlflow_db.username}:${aws_db_instance.mlflow_db.password}@${aws_db_instance.mlflow_db.endpoint}/${aws_db_instance.mlflow_db.db_name}" },
        {
          name  = "DEFAULT_ARTIFACT_ROOT"
          value = "s3://${var.pipeout_bucket_name}"
        },
        {
          name  = "MLFLOW_SERVER_ALLOWED_HOSTS"
          value = "*"
        },
        {
          name  = "MLFLOW_SERVER_CORS_ALLOWED_ORIGINS"
          value = "*"
        }
      ]
      portMappings = [
        { containerPort = var.mlflow_port }
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



resource "aws_ecs_task_definition" "preprocessing" {
  family                   = "preprocessing"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.preprocessing_cpu
  memory                   = var.preprocessing_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.preprocessing_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "preprocessing"
      image     = "${aws_ecr_repository.preprocessing.repository_url}:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/preprocessing"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
