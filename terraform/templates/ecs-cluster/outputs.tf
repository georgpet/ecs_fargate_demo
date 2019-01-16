output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = "${aws_ecs_cluster.ecs-cluster.name}"
}

output "ecs_cluster_id" {
  description = "ECS cluster id"
  value       = "${aws_ecs_cluster.ecs-cluster.id}"
}

output "ecs_cluster_sg_id" {
  description = "ECS cluster security group ID"
  value       = "${aws_security_group.ecs-cluster_sg.id}"
}