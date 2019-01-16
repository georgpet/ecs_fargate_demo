module "vpc" {
  source = "../templates/vpc"

  aws_region = "${var.region}"

  global_project = ""

  local_environment = "${var.environment}"

  global_name = ""
  # vpc

  vpc_name = "ECS-demo-VPC-${var.environment}"
  cidr     = "10.202.0.0/20"

  # Netmask 255.255.240.0
  # Wildcard Bits 0.0.15.255
  # IP range 10.202.0.0 - 10.202.15.255
  # Total Host 4096
  #
  # Except AWS takes exactly 5 IPs from each subnet
  #   see https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html

  azs                          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets              = ["10.202.0.0/24", "10.202.1.0/24", "10.202.2.0/24"]
  public_subnets               = ["10.202.6.0/24", "10.202.7.0/24", "10.202.8.0/24"]
  database_subnets             = []
  create_database_subnet_group = false
  enable_dns_support           = true
  enable_dns_hostnames         = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
  tags = {
    Project     = ""
    Environment = ""
  }
}

