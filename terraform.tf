terraform {

  required_providers {
    aws = {
      source  = "opentofu/aws"
      version = "6.46.0"
    }
  }
  required_version = ">= 1.11.6"
}
