
variable "ecs_cluster_name" {
  description = "ECS cluster name"
}
resource "aws_ecs_cluster" "test-ecs-cluster" {
    name = "${var.ecs_cluster_name}"
}
