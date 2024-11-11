variable "aws_region" {
  description = "Region"
  type        = string
}

variable "vpc1_cidr_block" {
  description = "Red para vpc1"
  type        = string
}

variable "vpc1_public_subnet_cidr" {
  description = "Red para subred 1"
  type        = string
}

variable "vpc1_private_subnet_cidr" {
  description = "Red para subnet privada"
  type        = string
}

variable "vpc2_cidr_block" {
  description = ""
  type        = string
}

variable "vpc2_private_subnet_cidr" {
  description = "Subnet privada de vpc2"
  type        = string
}

variable "availability_zone1" {
  description = "Zona disponibilidad 1"
  type        = string
}

variable "availability_zone2" {
  description = "Zonda disponibilidad2"
  type        = string
}

variable "allowed_cidr" {
  description = "IPs permitidas"
  type        = string
}

variable "instance_ami" {
  description = "ID del AMI debian"
  type        = string
}

variable "instance_type" {
  description = "tipo de instancia"
  type        = string
}

variable "key_name" {
  description = "nombre clave ssh"
  type        = string
}

variable "user_data" {
  description = "script ejecutar instancia"
  type        = string
}

variable "bastion_ip" {
  description = "Ip bastionado"
  type        = string
}

variable "s3_bucket_name" {
  description = "Nombre del bucket"
  type        = string
}

variable "ftp_container_name" {
  description = "Nombre del contenedor de ftp"
  type        = string
}
