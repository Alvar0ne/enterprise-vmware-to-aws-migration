
data "aws_caller_identity" "current" {}
# ============================================================
# S3 - DATA LAKE
# ============================================================

resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.project_name}-data-lake-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# ============================================================
# GLUE DATA CATALOG
# ============================================================

resource "aws_glue_catalog_database" "ecommerce" {
  name = "distrito_miami_analytics"
}

# ============================================================
# ROL PARA GLUE CRAWLER
# ============================================================


resource "aws_iam_role" "glue_crawler" {
  name = "${var.project_name}-glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "glue.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ============================================================
# PERMISOS PARA ESE ROL
# ============================================================


resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


# ============================================================
# PERMISOS DE LECTURA PARA NUESTROS DATOS DEL DATA LAKE EN S3
# ============================================================


resource "aws_iam_role_policy" "glue_read_data_lake" {
  name = "read-orders-data-lake"
  role = aws_iam_role.glue_crawler.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          aws_s3_bucket.data_lake.arn,
          "${aws_s3_bucket.data_lake.arn}/raw/orders/*"
        ]
      }
    ]
  })
}

# ============================================================
# CREAMOS EL CRAWLER
# ============================================================


resource "aws_glue_crawler" "orders" {
  name          = "${var.project_name}-orders-crawler"
  role          = aws_iam_role.glue_crawler.arn
  database_name = aws_glue_catalog_database.ecommerce.name

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/raw/orders/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}


# ============================================================
# CREAMOS WORKGROUP O CARPETA DENTRO DEL BUCKET PARA GUARDAR RESULTADOS DE ATHENA
# ============================================================


resource "aws_athena_workgroup" "analytics" {
  name = "${var.project_name}-analytics"

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.data_lake.bucket}/athena-results/"
    }
  }
}