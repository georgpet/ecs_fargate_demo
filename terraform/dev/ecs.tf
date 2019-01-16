module "ecs_cluster" {
  source = "../templates/ecs-cluster"

  
  ecs_cluster_name = "${var.environment}-cluster"
  vpc_id = "${module.vpc.vpc_id}"
  public_alb_sg = "${module.alb-public.this_security_group_id}" 
}