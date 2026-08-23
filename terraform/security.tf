
#SECURITY GROUP TRAFICO DESDE INTERNET A ALB

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security Group para el Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida permitida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}


# SECURITY GROUP TRAFICO APP DESDE ALB

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security Group para los servidores de aplicacion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Trafico desde el ALB"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    #Permite tráfico desde cualquier recurso que pertenezca al Security Group del ALB.
    security_groups = [aws_security_group.alb.id]
  }



  egress {
    description = "Salida permitida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}



# SECURITY GROUP RDS ( PERMITE SOLO EL TRAFICO POR PUERTO DE DB DESDE APP CON SECURITY GROUP AUTORIZADO)
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Permite PostgreSQL solo desde la capa de aplicacion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL desde APP-SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  /*ingress {
    description = "PostgreSQL desde VMware via Site-to-Site VPN"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["192.168.2.0/24"]
  }
*/


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS-SG"
  }
}