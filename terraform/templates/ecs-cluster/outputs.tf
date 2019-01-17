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

output "ecs_execution_role_arn" {
  description = "ECS execution role arn for fargate tasks"
  value       = "${aws_iam_role.ecs_execution_role.arn}"
}

output "ecs_cluster_log_group_name" {
  description = "ECS cluster log group name for fargate tasks"
  value       = "${aws_cloudwatch_log_group.cluster_log_group.name}"
}