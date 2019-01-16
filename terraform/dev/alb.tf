module "s3-alb-log-bucket" {
  source = "../templates/s3-alb-log-bucket"

  aws_region = "${var.region}"

  global_project = ""

  local_environment = "${var.environment}"

  global_name = "${var.environment}-alb-logs"

  create_logs_bucket = true
}



module "alb-public" {
  source = "../templates/alb"

  aws_region = "${var.region}"

  global_project = ""

  local_environment = "${var.environment}"

  global_name = "${var.environment}-alb-public"

  alb_is_internal = false

  alb_prefix = "-public-alb"

  alb_protocols = ["HTTP","HTTPS"]

  certificate_domain = "*.tietoaws.com"

  backend_port = 80

  health_check_path = "/"

  route53_record_prefix = "${var.environment}-public-alb"

  route53_zone_name = "${var.route53_zone_name}"

  assign_route53_private_zone = false

  vpc_id = "${module.vpc.vpc_id}"

  vpc_private_subnets = ["${module.vpc.private_subnets}"]

  vpc_cidr_block = "${module.vpc.vpc_cidr_block}"

  vpc_public_subnets = ["${module.vpc.public_subnets}"]

  direct_connect_cidr_block = ""

  logs_s3_bucket_id = "${module.s3-alb-log-bucket.logs_s3_bucket_id}"
  
}

