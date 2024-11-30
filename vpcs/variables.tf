variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc1_cidr_block" {
  description = "CIDR block for VPC1"
  type        = string
}

variable "vpc1_public_subnet_cidr" {
  description = "CIDR block for VPC1 public subnet"
  type        = string
}

variable "vpc1_private_subnet_cidr" {
  description = "CIDR block for VPC1 private subnet"
  type        = string
}

variable "vpc2_cidr_block" {
  description = "CIDR block for VPC2"
  type        = string
}

variable "vpc2_private_subnet_cidr" {
  description = "CIDR block for VPC2 private subnet"
  type        = string
}

variable "vpc2_public_subnet_cidr" {
  description = "CIDR block for VPC2 public subnet"
  type        = string
}

variable "availability_zone1" {
  description = "Availability zone for VPC1"
  type        = string
}

variable "availability_zone2" {
  description = "Availability zone for VPC2"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR block for allowed IPs"
  type        = string
}

variable "instance_ami" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Type of instance"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "user_data" {
  description = "User data script"
  type        = string
}

variable "bastion_ip" {
  description = "IP address of the bastion host"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for FTP"
  type        = string
}

variable "ftp_container_name" {
  description = "Name of the Docker container for FTP"
  type        = string
}


