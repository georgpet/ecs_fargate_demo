module "service1" {
  source = "../templates/ecs-service-fargate"

  service_name = "demo-service-1"

  ecs_cluster_name = "${module.ecs_cluster.ecs_cluster_name}"
  
  ecs_cluster_id = "${module.ecs_cluster.ecs_cluster_id}"

  environment = "${var.environment}"

  container_definiton_json_file = "hello-world-9080-container-def.json"

  container_name = "hello-world-9080"

  vpc_id = "${module.vpc.vpc_id}"

  container_port = "9080"

  security_groups = ["${module.ecs_cluster.ecs_cluster_sg_id}"]

  subnets = "${module.vpc.private_subnets}"

  alb_arn = "${module.alb-public.this_alb_arn}"

  #alb_arn_suffix = "${module.alb-public.this_alb_arn_suffix}"

  listener_arn = "${module.alb-public.this_alb_https_listener_arns}"

  #aws_zone_id = "${module.alb-public.this_alb_zone_id}"
  route53_zone_name = "${var.route53_zone_name}"

  alb_fqdn = "${module.alb-public.full_url}"

}
