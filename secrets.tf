resource "aws_secretsmanager_secret" "dockerhub_username" {
  name = "dockerhub_username"
}

resource "aws_secretsmanager_secret_version" "dockerhub_username" {
  secret_id     = aws_secretsmanager_secret.dockerhub_username.id
  secret_string = var.dockerhub_username
}

resource "aws_secretsmanager_secret" "dockerhub_token" {
  name = "dockerhub_token"
}

resource "aws_secretsmanager_secret_version" "dockerhub_token" {
  secret_id     = aws_secretsmanager_secret.dockerhub_token.id
  secret_string = var.dockerhub_token
}
