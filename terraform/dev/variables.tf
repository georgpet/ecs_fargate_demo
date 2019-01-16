variable "environment" {
  description = "Local name of this environment (eg, prod, stage, dev, feature1)"
}

variable "region" {
  description = "AWS region to use for all resources"
  default = "eu-west-1"
}

variable "route53_zone_name" {
  description = "Route53 zone name where ALB and services will be registered."
}