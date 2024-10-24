terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72.1"
    }
  }
  required_version = ">= 1.9.8"

  cloud {
    organization = "reizt"
    workspaces {
      name = "lambda-efs-sqlite"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      app = "les"
    }
  }
}

provider "archive" {}
