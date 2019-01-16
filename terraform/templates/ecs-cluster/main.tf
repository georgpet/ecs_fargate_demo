
resource "aws_ecs_cluster" "ecs-cluster" {
    name = "${var.ecs_cluster_name}"
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