output "aws_region" {
  description = "AWS region of the project"
  value       = "${var.aws_region}"
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = ["${module.vpc.private_route_table_ids}"]
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc.private_subnets}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.vpc.public_subnets}"]
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = ["${module.vpc.database_subnets}"]
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${module.vpc.vpc_cidr_block}"
}
