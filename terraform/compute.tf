data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# ACA PEDIMOS EL TEMPLATE

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.app_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.app_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  user_data = base64encode(<<-EOF
  #!/bin/bash
  set -e

  # Actualizar sistema e instalar dependencias
  apt-get update -y
  apt-get install -y ca-certificates curl unzip

  # Instalar Docker
  install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

  chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y

  apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  systemctl enable docker
  systemctl start docker

  # Instalar AWS CLI v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "/tmp/awscliv2.zip"

  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install

  # Autenticarse en Amazon ECR usando el IAM Role de la EC2
  aws ecr get-login-password --region us-east-1 | \
    docker login \
      --username AWS \
      --password-stdin ${split("/", aws_ecr_repository.app.repository_url)[0]}

  # Descargar imagen Docker desde ECR
  docker pull ${aws_ecr_repository.app.repository_url}:latest

  # Obtener credenciales de RDS desde Secrets Manager
  RDS_SECRET=$(aws secretsmanager get-secret-value \
    --region us-east-1 \
    --secret-id ${aws_db_instance.postgres.master_user_secret[0].secret_arn} \
    --query SecretString \
    --output text)

  RDS_USERNAME=$(echo "$RDS_SECRET" | python3 -c "import sys,json; print(json.load(sys.stdin)['username'])")
  RDS_PASSWORD=$(echo "$RDS_SECRET" | python3 -c "import sys,json; print(json.load(sys.stdin)['password'])")
  RDS_HOST=$(echo "$RDS_SECRET" | python3 -c "import sys,json; print(json.load(sys.stdin)['host'])")
  RDS_PORT=$(echo "$RDS_SECRET" | python3 -c "import sys,json; print(json.load(sys.stdin)['port'])")

  DATABASE_URL="postgresql://$RDS_USERNAME:$RDS_PASSWORD@$RDS_HOST:$RDS_PORT/${aws_db_instance.postgres.db_name}"



    # Ejecutar Distrito Miami usando PostgreSQL RDS
  docker run -d \
    --name distrito-miami-app \
    --restart unless-stopped \
    -p 3000:3000 \
    -e DATA_STORE=postgres \
    -e DATABASE_URL="$DATABASE_URL" \
    ${aws_ecr_repository.app.repository_url}:latest
    ${aws_ecr_repository.app.repository_url}:latest
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-app"
      Role = "application"
    }
  }

  tags = {
    Name = "${var.project_name}-app-launch-template"
  }


}






#ACA PEDIMOS LA EC2 A PARTIR DE TEMPLATE TODO A TRAVES DE AUTOSCALING GROUP YA QUE LO MINIMO PRENDIDO SON 2 EC2

resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-app-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 180
    }
  }

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "application"
    propagate_at_launch = true
  }
}