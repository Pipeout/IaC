provider "aws" {
  region = var.aws_region
}


terraform {
  backend "s3" {
    bucket = var.pipeout_bucket_name
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}
