variable "aws_region" {
  description = "Región para AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc1_cidr_block" {
  description = "Red para la vpc1"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc1_public_subnet_cidr" {
  description = "subred pública de la vpc1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc1_private_subnet_cidr" {
  description = "subred privada de la vpc1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vpc2_cidr_block" {
  description = "Red para la vpc2"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc2_private_subnet_cidr" {
  description = "subred privada para la vpc2"
  type        = string
  default     = "10.1.1.0/24"
}

variable "availability_zone1" {
  description = "Zona 1"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone2" {
  description = "Zona 2 en caso de que la zona 1 no  esté disponible"
  type        = string
  default     = "us-east-1b"
}

variable "allowed_cidr" {
  description = "Red para permitir todo el tráfico"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_ami" {
  description = "Instancia debian ."
  type        = string
  default     = "ami-064519b8c76274859"
}

variable "instance_type" {
  description = "Tipo de instancia."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nombre de la clave para ssh"
  type        = string
}

variable "user_data" {
  description = "Script que se ejecuta en la instancia en el momento de creación."
  type        = string
  default     = "script.sh"
}
