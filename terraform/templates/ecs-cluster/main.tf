
resource "aws_ecs_cluster" "ecs-cluster" {
    name = "${var.ecs_cluster_name}"
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs_task_execution_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }

  EOF
}

resource "aws_cloudwatch_log_group" "cluster_log_group" {
  name = "${var.ecs_cluster_name}-log-group"
  retention_in_days = 60
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "ecs_execution_role_policy"
  role   = "${aws_iam_role.ecs_execution_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
}
EOF
}


resource "aws_security_group" "ecs-cluster_sg" {
  name = "${var.ecs_cluster_name}_sg"
  description = "Test public access security group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups  = ["${var.public_alb_sg}"]
  }

  ingress {
    from_port = 9080
    to_port = 9080
    protocol = "tcp"
    security_groups  = ["${var.public_alb_sg}"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags {
    Name = "${var.ecs_cluster_name}_sg"
  }
}