resource "aws_autoscaling_group" "backend" {
  name = "${var.project_name}-backend-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  vpc_zone_identifier = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
  ]

  target_group_arns = [
    aws_lb_target_group.backend.arn,
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 600

  default_instance_warmup = 300

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity,
    ]
  }

  force_delete = true
}

resource "aws_autoscaling_policy" "backend_cpu" {
  name                   = "${var.project_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.backend.name

  policy_type = "TargetTrackingScaling"

  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = 60
    disable_scale_in = false
  }
}