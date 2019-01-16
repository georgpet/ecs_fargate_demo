variable "service_name" {
  description = "NEO service name"
}

variable "ecs_cluster_name" {
  description = "NEO service cluster name"
}

variable "ecs_cluster_id" {
  description = "NEO service cluster id"
}

variable "container_definiton_json_file" {
  description = "NEO service container definiton json filename"
}

variable "container_port" {
  description = "NEO service container port"
}

variable "container_name" {
  description = "NEO service container name"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "subnets" {
  description = "List of VPC subnets to launch the service in."
  type = "list"
}
variable "security_groups" {
  description = "list of security groups to assign to the service."
  type = "list"
}

variable "alb_arn" {
  description = "Application loadbalancer ARN."
}
/*
variable "alb_arn_suffix" {
  description = "Application loadbalancer ARN. Useful for passing to cloudwatch Metric dimension."
}*/

variable "listener_arn" {
  description = "Application loadbalancer ARN. Useful for passing to cloudwatch Metric dimension."
}
/*
variable "aws_zone_id" {
  description = "AWS zone where the DNS route 53 record will be added."
}*/

variable "alb_fqdn" {
  description = "Application loadbalancer fully qualified domain name."
}

variable "environment" {
  description = "Local name of this environment (eg, prod, stage, dev, feature1)"
}

variable "route53_zone_name" {
  description = "Route53 zone name to assign to this service"
}

