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