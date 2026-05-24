resource "aws_ecr_repository" "model_training" {
  name = var.model_training_image
}

resource "aws_ecr_repository" "feature_engineering" {
  name = var.feature_engineering_image
}

resource "aws_ecr_repository" "airflow" {
  name = var.airflow_image
}

resource "aws_ecr_repository" "mlflow" {
  name = var.mlflow_image
}
