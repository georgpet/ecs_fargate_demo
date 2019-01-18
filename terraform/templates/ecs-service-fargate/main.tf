resource "aws_ecs_service" "ecs-service" {
  	name            = "${var.service_name}"
  	cluster         = "${var.ecs_cluster_id}"
  	task_definition = "${aws_ecs_task_definition.ecs-service.arn}"
  	desired_count   = "${var.task_desired_count}"
	  health_check_grace_period_seconds = 60
    launch_type     = "FARGATE"

  	load_balancer {
    	target_group_arn  = "${aws_alb_target_group.ecs-target-group.arn}"
      container_port    = "${var.container_port}"
	    container_name    = "${var.container_name}"
    }

    network_configuration {
    	security_groups = ["${var.security_groups}"]
    	subnets         = ["${var.subnets}"]
		  assign_public_ip = false
  	}

    # Do not reset desired count if it was changed due to autoscaling
    lifecycle {
      ignore_changes = ["desired_count"]
    }

}



resource "aws_ecs_task_definition" "ecs-service" {
    family                = "${var.service_name}"
    #container_definitions = "${file("${var.container_definiton_json_file}")}"  

    container_definitions = <<DEFINITION
[
  {
            "name": "${var.container_name}",
            "image": "${var.container_image}",
            "cpu": ${var.cpu_reservation},
            "memory": ${var.memory_reservation},
            "networkMode": "awsvpc",
            "logConfiguration": {
              "logDriver": "awslogs",
              "options": {
                "awslogs-group": "${var.ecs_cluster_log_group_name}",
                "awslogs-region": "${var.region}",
                "awslogs-stream-prefix": "${var.service_name}"
              }
            },
            "portMappings": [
                {
                    "containerPort": ${var.container_port},
                    "hostPort": ${var.container_port}
                }
            ],
            "environment": [
                {
                  "name": "cluster_name",
                  "value": "${var.ecs_cluster_name}"
                },
                {
                  "name": "service_name",
                  "value": "${var.service_name}"
                }
            ],
            
            "essential": true
        }
]
DEFINITION

    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    cpu                      = "${var.cpu_reservation}"
    memory                   = "${var.memory_reservation}"
    
    
    execution_role_arn       = "${var.ecs_execution_role_arn}"
    task_role_arn            = "${var.ecs_execution_role_arn}"
    
}

#workaround for terraform not resolving dependencies between modules
resource "null_resource" "alb_exists" {
  triggers {
    alb_name = "${var.alb_arn}"
  }
}

resource "aws_alb_target_group" "ecs-target-group" {
    name                = "${var.service_name}-target-group"
    port                = "${var.container_port}"
    protocol            = "HTTP"
    vpc_id              = "${var.vpc_id}"
    target_type         = "ip"

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

   #workaround for terraform not resolving dependencies between modules
   depends_on = ["null_resource.alb_exists"]
}



resource "aws_lb_listener_rule" "host_based_routing_https" {
  listener_arn = "${var.https_listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.service_name}-${var.environment}.tietoaws.com"]
  }
}

resource "aws_lb_listener_rule" "host_based_routing_http" {
  listener_arn = "${var.http_listener_arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.ecs-target-group.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${var.service_name}-${var.environment}.tietoaws.com"]
  }
}

data "aws_route53_zone" "this" {
  name         = "${var.route53_zone_name}"
}

resource "aws_route53_record" "service_cname_record" {
  zone_id = "${data.aws_route53_zone.this.zone_id}"
  
  name    = "${var.service_name}-${var.environment}.tietoaws.com."
  type    = "CNAME"
  ttl     = "300"

  records        = ["${var.alb_fqdn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs-service_high_count" {
  alarm_name          = "${var.service_name}_high_count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
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
  evaluation_periods  = "1"
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
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = "${var.task_min_count}"
  max_capacity       = "${var.task_max_count}"

  depends_on = [
    "aws_ecs_service.ecs-service",
  ]
}

resource "aws_appautoscaling_policy" "up" {
  name               = "appScalingPolic${var.ecs_cluster_name}/${aws_ecs_service.ecs-service.name}ScaleUp"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.ecs-service.name}"
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
  name               = "appScalingPolicy${var.ecs_cluster_name}/${aws_ecs_service.ecs-service.name}ScaleDown"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.ecs-service.name}"
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

# CloudWatch Service Dashboard
resource "aws_cloudwatch_dashboard" "service_dashboard" {
  dashboard_name = "${var.ecs_cluster_name}-${var.service_name}-dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 21,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "${aws_alb_target_group.ecs-target-group.arn_suffix}", "LoadBalancer", "${var.alb_arn_suffix}", { "stat": "Average", "period": 60 } ],
                    [ ".", "RequestCountPerTarget", ".", ".", ".", ".", { "period": 60, "stat": "Sum", "visible": false } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.region}",
                "yAxis": {
                    "left": {
                        "min": 0
                    },
                    "right": {
                        "min": 0
                    }
                },
                "title": "Healthy host count"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 21,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", "${aws_alb_target_group.ecs-target-group.arn_suffix}", "LoadBalancer", "${var.alb_arn_suffix}", { "stat": "Sum", "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-1",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 21,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", "${aws_alb_target_group.ecs-target-group.arn_suffix}", { "stat": "Sum", "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-1",
                "title": "Request count per target"
            }
        }
    ]
}
 EOF
}
