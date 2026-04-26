// ASG + ALB module: creates a launch template and autoscaling group
// to run web application instances with simple autoscaling rules.

// 1) Launch Template: instance blueprint used by the ASG.
resource "aws_launch_template" "web_app" {
  name_prefix   = "web-app-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.tf_key.key_name

  vpc_security_group_ids = [aws_security_group.public_web_sg.id]

  // User data installs nginx and a small stress tool for testing.
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx stress-ng
              systemctl start nginx
              systemctl enable nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "asg-web-server"
    }
  }
}

// 2) Auto Scaling Group: keeps a small fleet of instances running across public subnets.
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  launch_template {
    id      = aws_launch_template.web_app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}

// 3) Scaling policy: simple step to add one instance when triggered.
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
}

// 4) CloudWatch alarm: monitors average CPU and triggers the scale-up policy.
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}