# ============================================================
# SNS - CANAL CENTRAL DE ALERTAS
# ============================================================

resource "aws_sns_topic" "infrastructure_alerts" {
  name = "${var.project_name}-infrastructure-alerts"

  tags = {
    Name = "${var.project_name}-infrastructure-alerts"
  }
}


# ============================================================
# CLOUDWATCH - TARGETS NO SALUDABLES DEL ALB
# ============================================================

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name        = "${var.project_name}-alb-unhealthy-targets"
  alarm_description = "Alerta cuando el Target Group tiene targets unhealthy"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Maximum"

  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    TargetGroup  = aws_lb_target_group.app.arn_suffix
    LoadBalancer = aws_lb.app.arn_suffix
  }

  alarm_actions = [
    aws_sns_topic.infrastructure_alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

# ============================================================
# CLOUDWATCH - ERRORES 5XX DEL ALB
# ============================================================

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name        = "${var.project_name}-alb-5xx"
  alarm_description = "Alerta cuando el ALB genera errores HTTP 5XX"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"

  period              = 60
  evaluation_periods  = 2
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
  }

  alarm_actions = [
    aws_sns_topic.infrastructure_alerts.arn
  ]

  treat_missing_data = "notBreaching"
}


# ============================================================
# CLOUDWATCH - CPU ALTA RDS
# ============================================================

resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name        = "${var.project_name}-rds-high-cpu"
  alarm_description = "Alerta cuando RDS mantiene CPU alta"

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  alarm_actions = [
    aws_sns_topic.infrastructure_alerts.arn
  ]

  treat_missing_data = "notBreaching"
}

# ============================================================
# CLOUDWATCH - ESPACIO LIBRE RDS
# ============================================================

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name        = "${var.project_name}-rds-low-storage"
  alarm_description = "Alerta cuando RDS tiene menos de 2 GB de almacenamiento libre"

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"
  statistic   = "Average"

  period              = 300
  evaluation_periods  = 1
  threshold           = 2147483648
  comparison_operator = "LessThanThreshold"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  alarm_actions = [
    aws_sns_topic.infrastructure_alerts.arn
  ]

  treat_missing_data = "notBreaching"
}


# ============================================================
# SNS - SUSCRIPCIÓN POR EMAIL
# ============================================================

resource "aws_sns_topic_subscription" "infrastructure_alerts_email" {
  topic_arn = aws_sns_topic.infrastructure_alerts.arn
  protocol  = "email"
  endpoint  = "alvaro.poncen@utem.cl"
}


# ============================================================
# CLOUDWATCH LOGS - APLICACION
# ============================================================

resource "aws_cloudwatch_log_group" "app" {
  name              = "/enterprise-vmware-aws/app"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-app-logs"
  }
}