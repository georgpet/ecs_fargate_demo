variable "aws_region" {
  description = "AWS region to use for all resources"
}

variable "global_name" {
  description = "Global name of this project/account with environment"
}

variable "global_project" {
  description = "Global name of this project (without environment)"
}

variable "local_environment" {
  description = "Local name of this environment (eg, prod, stage, dev, feature1)"
}

variable "tags" {
  type = "map"
}

# VPC
variable "vpc_name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  default     = "0.0.0.0/0"
}

variable "azs" {
  description = "A list of availability zones in the region"
  default     = []
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  default     = []
}

variable "database_subnets" {
  type        = "list"
  description = "A list of database subnets"
  default     = []
}

variable "create_database_subnet_group" {
  description = "Controls if database subnet group should be created"
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}
