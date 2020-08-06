provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}