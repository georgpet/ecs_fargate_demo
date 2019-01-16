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

variable "create_logs_bucket" {
  description = "Specify true to create S3 logs bucket"
  default     = false
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = true
}

variable "logs_bucket_tags" {
  description = "Map of tags to assign to S3 logs bucket"
  type        = "map"
  default     = {}
}
