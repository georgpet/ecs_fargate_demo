variable "ecs_cluster_name" {
  description = "ECS cluster name"
}
variable "vpc_id" {
  description = "VPC ID"
}

variable "public_alb_sg" {
  description = "Security group of public load balancer."
}
