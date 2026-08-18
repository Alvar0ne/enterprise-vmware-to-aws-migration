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