variable "aws_region" {
  description = "AWS region to use for all resources"
}

variable "global_name" {
  description = "Global name of this project/account with environment"
}

variable "global_project" {
  description = "Global name of this project (without environment)"
}

variable "local_environment" {
  description = "Local name of this environment (eg, prod, stage, dev, feature1)"
}

variable "alb_prefix" {
  description = "ALB prefix to append to name (hint: start with '-' or leave empty)"
}

variable "alb_is_internal" {
  description = "Boolean to specify if ALB is internal"
}

variable "alb_protocols" {
  description = "The protocols the ALB accepts. e.g.: [\"HTTP\"]"
  type        = "list"
  default     = ["HTTPS"]
}

variable "certificate_domain" {
  description = "ACM certificate domain to use by this ALB"
}

variable "backend_port" {
  description = "Backend/instance port to use for ALB"
}

variable "health_check_path" {
  description = "Health check path to use for ALB"
}

variable "route53_record_prefix" {
  description = "Route53 record prefix (hint: leave empty to use directly the zone name)"
  default     = ""
}

variable "route53_zone_name" {
  description = "Route53 zone name to assign to this ALB"
}

variable "assign_route53_private_zone" {
  description = "Assign Route53 private zone to this ALB"
}

variable "deregistration_delay" {
  description = "The amount time to wait before changing the state of a deregistering target from draining to unused."
  default     = 300
}

variable "tags" {
  description = "Map of tags to assign to ALB"
  type        = "map"
  default     = {}
}

# VPC variables

variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "vpc_private_subnets" {
  description = "List of IDs of private subnets"
  type        = "list"
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
}

variable "vpc_public_subnets" {
  description = "List of IDs of public subnets"
  type        = "list"
}

# VPC peering

variable "direct_connect_cidr_block" {
  description = "CIDR block of Direct Connect"
}

# S3 log bucket

variable "logs_s3_bucket_id" {
  description = "The name of logs bucket"
  default = ""
}
