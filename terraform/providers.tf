
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "Enterprise-VMware-to-AWS"
      Environment = "lab"
      ManagedBy   = "Terraform"
    }

  }
}

data "archive_file" "order_analytics" {
  type        = "zip"
  source_file = "${path.module}/lambda/order_analytics.py"
  output_path = "${path.module}/lambda/order_analytics.zip"
}