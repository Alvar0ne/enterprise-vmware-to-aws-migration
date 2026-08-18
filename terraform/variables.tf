variable "project_name" {
  description = "Nombre utilizado para identificar los recursos del proyecto"
  type        = string
  default     = "enterprise-vmware-aws"
}

variable "vpc_cidr" {
  description = "Rango CIDR utilizado por la VPC"
  type        = string
  default     = "10.0.0.0/16"
}


variable "app_instance_type" {
  description = "Tipo de instancia EC2 para los servidores de aplicacion"
  type        = string
  default     = "t3.micro"
}

variable "app_volume_size" {
  description = "Tamano del volumen EBS raiz de las instancias de aplicacion"
  type        = number
  default     = 20
}