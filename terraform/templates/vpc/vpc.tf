module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v1.4.0"
  name   = "${var.vpc_name}"
  cidr   = "${var.cidr}"

  # Netmask 255.255.240.0
  # Wildcard Bits 0.0.15.255
  # IP range 10.202.0.0 - 10.202.15.255
  # Total Host 4096
  #
  # Except AWS takes exactly 5 IPs from each subnet
  #   see https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html

  azs                          = ["${var.azs}"]
  private_subnets              = ["${var.private_subnets}"]
  public_subnets               = ["${var.public_subnets}"]
  database_subnets             = ["${var.database_subnets}"]
  create_database_subnet_group = "${var.create_database_subnet_group}"
  enable_dns_support           = "${var.enable_dns_support}"
  enable_dns_hostnames         = "${var.enable_dns_hostnames}"
  enable_nat_gateway           = "${var.enable_nat_gateway}"
  single_nat_gateway           = "${var.single_nat_gateway}"
  tags                         = "${var.tags}"
}
