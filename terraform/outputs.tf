output "vpc_id" {
  description = "ID de la VPC creada por Terraform"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = aws_vpc.main.cidr_block
}


output "public_subnet_ids" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}


output "alb_security_group_id" {
  description = "ID del Security Group del Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "ID del Security Group de los servidores de aplicacion"
  value       = aws_security_group.app.id
}

output "rds_security_group_id" {
  description = "ID del Security Group de PostgreSQL RDS"
  value       = aws_security_group.rds.id
}

output "ubuntu_ami_id" {
  description = "AMI seleccionada para Ubuntu Server 24.04"
  value       = data.aws_ami.ubuntu.id
}

output "app_launch_template_id" {
  description = "ID del Launch Template de aplicacion"
  value       = aws_launch_template.app.id
}

output "app_autoscaling_group_name" {
  description = "Nombre del Auto Scaling Group de aplicacion"
  value       = aws_autoscaling_group.app.name
}

output "alb_dns_name" {
  description = "DNS publico del Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "target_group_arn" {
  description = "ARN del Target Group de la aplicacion"
  value       = aws_lb_target_group.app.arn
}