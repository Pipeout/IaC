provider "aws" {
  region = var.aws_region
}


terraform {
  backend "s3" {
    bucket = "pipeout-database"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}
