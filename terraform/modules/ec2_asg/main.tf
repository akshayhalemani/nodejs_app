resource "aws_security_group" "asg_sg" {
  name        = "${var.name}-sg"
  description = "Security group for app servers"
  vpc_id = var.app_vpc_id

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.10.0.0/16"]
  }

  ingress { 
    from_port = var.app_port; 
    to_port = var.app_port; 
    protocol = "tcp"; 
    cidr_blocks = ["10.10.0.0/16"] 
    }

  egress { 
    from_port = var.db_port; 
    to_port = var.db_port; 
    protocol = "tcp"; 
    cidr_blocks = ["10.10.0.0/16"] 
    }
}

resource "aws_launch_template" "app_asg_lt" {
  image_id      = var.ami
  instance_type = var.instance_type
  security_group_names = [aws_security_group.asg_sg.name]
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
      delete_on_termination = true
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = var.min_size
  min_size         = var.min_size
  max_size         = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns    = var.target_group_arns
  health_check_type         = "EC2"
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.app_asg_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.name}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale out when CPU > 70%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.name}-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 15
  alarm_description   = "Scale in when CPU < 15%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

