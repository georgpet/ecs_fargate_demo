output "logs_s3_bucket_id" {
  description = "The name of logs bucket"
  value       = "${element(concat(aws_s3_bucket.logs.*.id, list("")), 0)}"
}

output "logs_s3_bucket_arn" {
  description = "ARN of logs bucket"
  value       = "${element(concat(aws_s3_bucket.logs.*.arn, list("")), 0)}"
}

output "logs_s3_bucket_domain_name" {
  description = "Domain name of logs bucket"
  value       = "${element(concat(aws_s3_bucket.logs.*.bucket_domain_name, list("")), 0)}"
}
