resource "aws_iam_role" "ec2_ecr_role" {
  name = "enterprise-vmware-aws-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "enterprise-vmware-aws-ec2-ecr-role"
    Environment = "lab"
    Project     = "enterprise-vmware-to-aws-migration"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_readonly" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "enterprise-vmware-aws-ec2-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

resource "aws_iam_role_policy" "ec2_read_rds_secret" {
  name = "ec2-read-rds-secret"
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = aws_db_instance.postgres.master_user_secret[0].secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy" "ec2_s3_images" {
  name = "ec2-s3-images"
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "arn:aws:s3:::distritomiami-images-prod/productos/*"
      }
    ]
  })
}


resource "aws_iam_role_policy" "ec2_cloudwatch_logs" {
  name = "ec2-cloudwatch-logs"
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.app.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_publish_eventbridge" {
  name = "ec2-publish-eventbridge"
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "events:PutEvents"
        ]

        Resource = aws_cloudwatch_event_bus.ecommerce.arn
      }
    ]
  })
}

//ROL LAMBA ANALITYCS

resource "aws_iam_role" "order_analytics_lambda" {
  name = "${var.project_name}-order-analytics-lambda-role"

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
}

//POLICY ROL LAMBA ANALITYCS CLOUDWATCH

resource "aws_iam_role_policy_attachment" "order_analytics_logs" {
  role       = aws_iam_role.order_analytics_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


//POLICY ROL LAMBA ANALITYCS S3 DATA LAKE
resource "aws_iam_role_policy" "order_analytics_s3" {
  name = "write-orders-data-lake"
  role = aws_iam_role.order_analytics_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.data_lake.arn}/raw/orders/*"
      }
    ]
  })
}