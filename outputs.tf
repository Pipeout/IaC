# outputs.tf

# ECR URLs — CI/CD needs these to push images
output "ecr_airflow_url" {
  value = aws_ecr_repository.airflow.repository_url
}

output "ecr_mlflow_url" {
  value = aws_ecr_repository.mlflow.repository_url
}

output "ecr_model_training_url" {
  value = aws_ecr_repository.model_training.repository_url
}

output "ecr_feature_engineering_url" {
  value = aws_ecr_repository.feature_engineering.repository_url
}

# Cluster name — Airflow EcsRunTaskOperator needs this
output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

# Subnet and security group — Airflow needs these for network_configuration
output "public_subnet_id" {
  value = aws_subnet.public_a.id
}

output "ephemeral_security_group_id" {
  value = aws_security_group.ephemeral.id
}
