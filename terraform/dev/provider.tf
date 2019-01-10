# Setup our aws provider

variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

provider "aws" {
  region      = "${var.aws_region}"
}
