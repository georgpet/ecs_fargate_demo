output "ecs-service-URL" {
  value = "${aws_route53_record.service_cname_record.fqdn}"
}
