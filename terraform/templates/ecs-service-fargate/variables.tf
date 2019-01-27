variable "service_name" {
  description = "NEO service name"
}

variable "region" {
  description = "AWS region to use for all resources"
}

variable "ecs_cluster_name" {
  description = "ECS service cluster name"
}

variable "ecs_cluster_id" {
  description = "ECS service cluster id"
}

variable "container_image" {
  description = "Container registry with Docker image."
}

variable "container_port" {
  description = "service container port"
}

variable "container_name" {
  description = "service container name"
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

variable "alb_arn_suffix" {
  description = "Application loadbalancer ARN. Useful for passing to cloudwatch Metric dimension."
}

variable "https_listener_arn" {
  description = "Application loadbalancer ARN. Useful for passing to cloudwatch Metric dimension."
}

variable "http_listener_arn" {
  description = "Application loadbalancer ARN. Useful for passing to cloudwatch Metric dimension."
}

variable "alb_fqdn" {
  description = "Application loadbalancer fully qualified domain name."
}

variable "environment" {
  description = "Local name of this environment (eg, prod, stage, dev, feature1)"
}

variable "route53_zone_name" {
  description = "Route53 zone name to assign to this service"
}

variable "ecs_execution_role_arn" {
  description = "ECS execution role arn for fargate tasks"
}

variable "ecs_cluster_log_group_name" {
  description = "ECS cluster log group name for fargate tasks"
}

variable "task_desired_count" {
  description = "Initial desired count for service tasks"
  default = 1
}

variable "task_min_count" {
  description = "Minimum task count for service  autoscaling"
  default = 1
}

variable "task_max_count" {
  description = "Minimum task count for service autoscaling"
  default = 5
}

variable "cpu_reservation" {
  description = "CPU reservation for container instance."
  default = 512
}

variable "memory_reservation" {
  description = "Memory reservation for container instance."
  default = 512
}

variable "high_count_threshold" {
  description = "Number of request per minute per target to scale up."
  default = 100
}

variable "low_count_threshold" {
  description = "Number of request per minute per target to scale down."
  default = 50
}
