# log groups so ECS has somewhere to write
resource "aws_cloudwatch_log_group" "airflow" {
  name              = "/ecs/airflow"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "mlflow" {
  name              = "/ecs/mlflow"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "model_training" {
  name              = "/ecs/model_training"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "feature_engineering" {
  name              = "/ecs/feature_engineering"
  retention_in_days = 7
}


resource "aws_cloudwatch_log_group" "preprocessing" {
  name              = "/ecs/preprocessing"
  retention_in_days = 7
}
