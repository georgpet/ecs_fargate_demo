output "ecs-service-1st-HTTP-URL" {
  value = "http://${module.service-1st.ecs-service-URL}"
}
output "ecs-service-1st-HTTPS-URL" {
  value = "https://${module.service-1st.ecs-service-URL}"
}

module "service-1st" {
  source = "../templates/ecs-service-fargate"

  service_name = "demo-service-1st"

  ecs_cluster_name = "${module.ecs_cluster.ecs_cluster_name}"
  
  ecs_cluster_id = "${module.ecs_cluster.ecs_cluster_id}"

  environment = "${var.environment}"

  container_image = "511726569835.dkr.ecr.eu-west-1.amazonaws.com/ecs_demo_task:0.1"

  container_name = "ecs_demo_task"

  high_count_threshold = "110"

  low_count_threshold = "90"

  vpc_id = "${module.vpc.vpc_id}"

  container_port = "80"

  security_groups = ["${module.ecs_cluster.ecs_cluster_sg_id}"]

  subnets = "${module.vpc.private_subnets}"

  alb_arn = "${module.alb-public.this_alb_arn}"

  alb_arn_suffix = "${module.alb-public.this_alb_arn_suffix}"

  https_listener_arn = "${module.alb-public.this_alb_https_listener_arns}"

  http_listener_arn = "${module.alb-public.this_alb_http_listener_arns}"

  route53_zone_name = "${var.route53_zone_name}"

  alb_fqdn = "${module.alb-public.full_url}"

  ecs_execution_role_arn = "${module.ecs_cluster.ecs_execution_role_arn}"

  ecs_cluster_log_group_name = "${module.ecs_cluster.ecs_cluster_log_group_name}"

  region = "${var.region}"

}
