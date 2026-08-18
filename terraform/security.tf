
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

#SECURITY GROUP RDS, PERMITE EL TRAFICO DESDE el SG DE LA APP PUERTO DE POSTGRESS

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security Group para PostgreSQL RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL desde servidores de aplicacion"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    #PERMITE TRAFICO SOLO DESDE ESE SG PUERTO 5432
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Salida permitida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}