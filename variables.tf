variable "aws_region" {
  type = string
  description = "Default region"
}

variable "dockerhub_username"{
  type = string
  description = "Docker Hub username"
  sensitive = true
}

variable "dockerhub_token" {
  type = string
  description = "Docker Hub token"
  sensitive = true
}
