resource "aws_ecs_service" "neo-ecs-service" {
  	name            = "${var.service_name}"
  	iam_role        = "${aws_iam_role.ecs-service-role.name}"
  	cluster         = "${data.aws_ecs_cluster.neo-cluster.id}"
  	task_definition = "${aws_ecs_task_definition.neo-ecs-service.family}:${max("${aws_ecs_task_definition.neo-ecs-service.revision}", "${data.aws_ecs_task_definition.neo-ecs-service.revision}")}"
  	desired_count   = 1
	  health_check_grace_period_seconds = 60

  	load_balancer {
    	target_group_arn  = "${aws_alb_target_group.ecs-target-group.arn}"
        container_port    = "${var.container_port}"
	    container_name    = "${var.container_name}"
    }

    # Do not reset desired count if it was changed due to autoscaling
    lifecycle {
      ignore_changes = ["desired_count"]
    }

    #depends_on = ["aws_iam_role.ecs-service-role","aws_alb_listener.alb-listener"]
}

data "aws_ecs_cluster" "neo-cluster"{
    cluster_name = "${var.ecs_cluster_name}"
}

data "aws_ecs_task_definition" "neo-ecs-service" {
  task_definition = "${aws_ecs_task_definition.neo-ecs-service.family}"
}

resource "aws_ecs_task_definition" "neo-ecs-service" {
    family                = "${var.service_name}"
    container_definitions = "${file("${var.container_definiton_json_file}")}"  
}


resource "aws_alb_target_group" "ecs-target-group" {
    name                = "${var.service_name}-target-group"
    port                = "${var.container_port}"
    protocol            = "HTTP"
    vpc_id              = "${var.vpc_id}"

    deregistration_delay = "5"

    health_check {
        healthy_threshold   = "2"
        unhealthy_threshold = "2"
        interval            = "10"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags {
      Name = "${var.service_name}-target-group"
    }
}

resource "aws_alb_listener" "alb-listener" {
    load_balancer_arn = "arn:aws:elasticloadbalancing:eu-west-1:456893923059:loadbalancer/app/telia-no-neo-dev-internal-st1/6c798b70ffd17a5f"
    port              = "9999"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
        type             = "forward"
    }
}

resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = "arn:aws:elasticloadbalancing:eu-west-1:456893923059:listener/app/telia-no-neo-dev-internal-st1/6c798b70ffd17a5f/44bdf56834466830"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.service_name}-st1aws.neo-dev.purplegears.net"]
  }
}

resource "aws_route53_record" "service_cname_record" {
  zone_id = "ZRG1AU4ZKZZZ6"
  name    = "${var.service_name}-st1aws.neo-dev.purplegears.net."
  type    = "CNAME"
  ttl     = "300"

  records        = ["st1aws.neo-dev.purplegears.net"]
}

resource "aws_iam_role" "ecs-service-role" {
    name                = "ecs-service-role"
    path                = "/"
    assume_role_policy  = "${data.aws_iam_policy_document.ecs-service-policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs-service-role-attachment" {
    role       = "${aws_iam_role.ecs-service-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs-service-policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs.amazonaws.com"]
        }
    }
}

resource "aws_cloudwatch_metric_alarm" "ecs-service_high_count" {
  alarm_name          = "${var.service_name}_high_count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "100"

  dimensions {
    TargetGroup = "${aws_alb_target_group.ecs-target-group.arn_suffix}"
  }

  alarm_description = "Scale up if RequestCountPerTarget is above N% for N duration"
  alarm_actions     = ["${aws_appautoscaling_policy.up.arn}"]

  depends_on = [
    "aws_appautoscaling_policy.up",
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs-service_low_count" {
  alarm_name          = "${var.service_name}_low_count"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "50"

  dimensions {
    TargetGroup = "${aws_alb_target_group.ecs-target-group.arn_suffix}"
  }

  alarm_description = "Scale down if RequestCountPerTarget is less N% for N duration"
  alarm_actions     = ["${aws_appautoscaling_policy.down.arn}"]

   depends_on = [
    "aws_appautoscaling_policy.down",
  ]

}

#
# Application AutoScaling resources
#
resource "aws_appautoscaling_target" "main" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.neo-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = "1"
  max_capacity       = "10"

  depends_on = [
    "aws_ecs_service.neo-ecs-service",
  ]
}

resource "aws_appautoscaling_policy" "up" {
  name               = "appScalingPolic${var.ecs_cluster_name}/${aws_ecs_service.neo-ecs-service.name}ScaleUp"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.neo-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "90"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.main",
  ]
}

resource "aws_appautoscaling_policy" "down" {
  name               = "appScalingPolicy${var.ecs_cluster_name}/${aws_ecs_service.neo-ecs-service.name}ScaleDown"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.neo-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "90"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.main",
  ]
}