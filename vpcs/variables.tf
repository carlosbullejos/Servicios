variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc1_cidr_block" {
  description = "CIDR block for VPC1."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc1_public_subnet_cidr" {
  description = "CIDR block for public subnet in VPC1."
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc1_private_subnet_cidr" {
  description = "CIDR block for private subnet in VPC1."
  type        = string
  default     = "10.0.2.0/24"
}

variable "vpc2_cidr_block" {
  description = "CIDR block for VPC2."
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc2_private_subnet_cidr" {
  description = "CIDR block for private subnet in VPC2."
  type        = string
  default     = "10.1.1.0/24"
}

variable "availability_zone1" {
  description = "Availability zone for VPC1."
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone2" {
  description = "Availability zone for VPC2."
  type        = string
  default     = "us-east-1b"
}

variable "allowed_cidr" {
  description = "CIDR block allowed for FTP ports."
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_ami" {
  description = "AMI ID for the FTP instance."
  type        = string
  default     = "ami-064519b8c76274859"
}

variable "instance_type" {
  description = "Instance type for the FTP instance."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key to use for the instance."
  type        = string
}

variable "user_data" {
  description = "Path to the user data script file."
  type        = string
  default     = "script.sh"
}
