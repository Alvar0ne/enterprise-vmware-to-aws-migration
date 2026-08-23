
#ACA NO CREAMOS OTROAS SUBNET PARA LA RDS, SINO QUE AGRUPAMOS LAS DOS SUBNET PRIVADAS EXISTENTES, DONDE VIVIRA LA DB, PARA QUE RDS SEPA DONDE ESTAR

resource "aws_db_subnet_group" "app" {
  name = "enterprise-vmware-aws-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name        = "enterprise-vmware-aws-db-subnet-group"
    Environment = "lab"
    Project     = "enterprise-vmware-to-aws-migration"
  }
}

# ACA CERAMOS LA INSTANCIA DB

resource "aws_db_instance" "postgres" {
  identifier = "distrito-miami-postgres"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "distritomiami"
  username = "dbadmin"

  manage_master_user_password = true

  multi_az = true

  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  backup_retention_period = 1

  skip_final_snapshot = true

  deletion_protection = false

  tags = {
    Name        = "distrito-miami-postgres"
    Environment = "lab"
    Project     = "enterprise-vmware-to-aws-migration"
  }
}
