# ============================================================
# EVENTBRIDGE - BUS DE EVENTOS DEL E-COMMERCE
# ============================================================

resource "aws_cloudwatch_event_bus" "ecommerce" {
  name = "${var.project_name}-events"
}


# ============================================================
# EVENTBRIDGE - REGLA ORDER_CREATED
# ============================================================

resource "aws_cloudwatch_event_rule" "order_created" {
  name           = "${var.project_name}-order-created"
  event_bus_name = aws_cloudwatch_event_bus.ecommerce.name

  event_pattern = jsonencode({
    source = [
      "distrito-miami.checkout"
    ]

    detail-type = [
      "order_created"
    ]
  })
}

# ============================================================
# EVENTBRIDGE → SQS ORDERS
# ============================================================

resource "aws_cloudwatch_event_target" "order_created_to_sqs" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.ecommerce.name

  arn = aws_sqs_queue.orders.arn
}


resource "aws_sqs_queue_policy" "orders_eventbridge" {
  queue_url = aws_sqs_queue.orders.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowEventBridgeSendMessage"
        Effect = "Allow"

        Principal = {
          Service = "events.amazonaws.com"
        }

        Action = "sqs:SendMessage"

        Resource = aws_sqs_queue.orders.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.order_created.arn
          }
        }
      }
    ]
  })
}


# ============================================================
# EVENTBRIDGE → ORDER ANALITYCS
# ============================================================

resource "aws_cloudwatch_event_target" "order_created_to_analytics" {
  rule           = aws_cloudwatch_event_rule.order_created.name
  event_bus_name = aws_cloudwatch_event_bus.ecommerce.name

  target_id = "OrderAnalytics"
  arn       = aws_lambda_function.order_analytics.arn
}
# ============================================================
# autorizamos a EventBridge para invocar esa Lambda:
# ============================================================


resource "aws_lambda_permission" "eventbridge_order_analytics" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_analytics.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.order_created.arn
}