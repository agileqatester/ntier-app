resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/${var.name_prefix}/app"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.name_prefix}-log-group"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 70
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  alarm_description   = "Alarm when CPU exceeds 70%"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  actions_enabled = true
  alarm_actions = ["arn:aws:sns:us-east-1:111122223333:my-topic"]
  ok_actions    = ["arn:aws:sns:us-east-1:111122223333:my-topic"]

  tags = {
    Name = "${var.name_prefix}-cpu-alarm"
  }
}
