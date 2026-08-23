resource "aws_ecr_repository" "app" {
  name                 = "distrito-miami-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "distrito-miami-app"
    Environment = "lab"
    Project     = "enterprise-vmware-to-aws-migration"
  }
}