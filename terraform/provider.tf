terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.57.0"
    }
  }
}

provider "aws" {
  profile = "adfs"
  region  = var.aws_region
}
