data "aws_elb_service_account" "this" {}

locals {
  bucket = "${var.global_name}-logs-${var.aws_region}"

  logs_bucket_tags = "${merge(
  var.logs_bucket_tags,
  map("Name", var.global_name),
  map("Project", var.global_project),
  map("Environment", var.local_environment)
  )}"
}

data "aws_iam_policy_document" "logs" {
  statement {
    sid = "AllowToPutLoadBalancerLogsToS3Bucket"

    actions = [
      "s3:PutObject",
    ]

    principals = {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.this.arn}"]
    }

    resources = [
      "arn:aws:s3:::${local.bucket}/*",
    ]
  }
}

resource "aws_s3_bucket" "logs" {
  count = "${var.create_logs_bucket}"

  bucket        = "${local.bucket}"
  region        = "${var.aws_region}"
  acl           = "private"
  policy        = "${data.aws_iam_policy_document.logs.json}"
  force_destroy = "${var.force_destroy}"

  tags = "${local.logs_bucket_tags}"
}
