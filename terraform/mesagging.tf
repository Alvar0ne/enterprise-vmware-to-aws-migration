# ============================================================
# SQS - DEAD LETTER QUEUE
# ============================================================

resource "aws_sqs_queue" "orders_dlq" {
  name = "${var.project_name}-orders-dlq"

  # Los mensajes fallidos se conservarán durante 14 días
  message_retention_seconds = 1209600

  tags = {
    Name = "${var.project_name}-orders-dlq"
  }
}


# ============================================================
# SQS - COLA PRINCIPAL DE PEDIDOS
# ============================================================

resource "aws_sqs_queue" "orders" {
  name = "${var.project_name}-orders"

  # Mientras Lambda procesa un mensaje, este queda invisible
  # para otros consumidores durante 60 segundos
  visibility_timeout_seconds = 60

  # Los mensajes normales pueden permanecer hasta 4 días
  message_retention_seconds = 345600

  # Después de 3 recepciones fallidas,
  # el mensaje será enviado a la DLQ
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.orders_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name = "${var.project_name}-orders"
  }
}


# ============================================================
# SQS - PERMITIR QUE ORDERS UTILICE LA DLQ
# ============================================================

resource "aws_sqs_queue_redrive_allow_policy" "orders_dlq" {
  queue_url = aws_sqs_queue.orders_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"

    sourceQueueArns = [
      aws_sqs_queue.orders.arn
    ]
  })
}


# ============================================================
# LAMBDA - EMPAQUETAR CÓDIGO PYTHON
# ============================================================

data "archive_file" "order_processor" {
  type        = "zip"
  source_file = "${path.module}/lambda/order_processor.py"
  output_path = "${path.module}/lambda/order_processor.zip"
}


# ============================================================
# IAM - ROLE PARA LAMBDA
# ============================================================

resource "aws_iam_role" "order_processor_lambda" {
  name = "${var.project_name}-order-processor-lambda-role"

  # Permite que AWS Lambda asuma este Role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-order-processor-lambda-role"
  }
}


# ============================================================
# IAM - PERMISOS LAMBDA PARA SQS + CLOUDWATCH LOGS
# ============================================================

resource "aws_iam_role_policy_attachment" "order_processor_sqs" {
  role = aws_iam_role.order_processor_lambda.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}


# ============================================================
# LAMBDA - PROCESADOR DE PEDIDOS
# ============================================================

resource "aws_lambda_function" "order_processor" {
  function_name = "${var.project_name}-order-processor"

  # ZIP generado por archive_file
  filename         = data.archive_file.order_processor.output_path
  source_code_hash = data.archive_file.order_processor.output_base64sha256

  # IAM Role
  role = aws_iam_role.order_processor_lambda.arn

  # order_processor.py → lambda_handler()
  handler = "order_processor.lambda_handler"

  runtime = "python3.12"

  timeout = 30

  tags = {
    Name = "${var.project_name}-order-processor"
  }

  depends_on = [
    aws_iam_role_policy_attachment.order_processor_sqs
  ]
}


# ============================================================
# SQS → LAMBDA
# ============================================================

resource "aws_lambda_event_source_mapping" "orders" {
  event_source_arn = aws_sqs_queue.orders.arn

  function_name = aws_lambda_function.order_processor.arn

  # Para el laboratorio procesaremos un mensaje por invocación
  batch_size = 1

  enabled = true
}



# ============================================================
# LAMBDA - ANALITYCS
# ============================================================

resource "aws_lambda_function" "order_analytics" {
  function_name = "${var.project_name}-order-analytics"

  role    = aws_iam_role.order_analytics_lambda.arn
  handler = "order_analytics.lambda_handler"
  runtime = "python3.12"

  filename         = data.archive_file.order_analytics.output_path
  source_code_hash = data.archive_file.order_analytics.output_base64sha256

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      DATA_LAKE_BUCKET = aws_s3_bucket.data_lake.bucket
    }
  }
}