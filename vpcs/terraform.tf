provider "aws" {
  region = var.aws_region
}

# Creación de la VPC 1
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc1_cidr_block
}

resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
}

# Creación de la subred pública
resource "aws_subnet" "vpc1_public_subnet" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.vpc1_public_subnet_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true
}

# Creación de la subred privada
resource "aws_subnet" "vpc1_private_subnet" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.vpc1_private_subnet_cidr
  availability_zone = var.availability_zone1
}

# VPC 2
resource "aws_vpc" "vpc2" {
  cidr_block = var.vpc2_cidr_block
}

resource "aws_subnet" "vpc2_private_subnet" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = var.vpc2_private_subnet_cidr
  availability_zone = var.availability_zone2
}

# VPC Peering entre VPC1 y VPC2
resource "aws_vpc_peering_connection" "vpc1_vpc2_peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true
}

# Rutas para la conexión entre VPCs
resource "aws_route" "route_vpc1_to_vpc2" {
  route_table_id           = aws_route_table.vpc1_private_route_table.id
  destination_cidr_block   = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2_peering.id
}

resource "aws_route" "route_vpc2_to_vpc1" {
  route_table_id           = aws_route_table.vpc2_private_route_table.id
  destination_cidr_block   = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2_peering.id
}

# Bucket S3 para almacenamiento del FTP
resource "aws_s3_bucket" "ftp_storage" {
  bucket = "s3-carlosbullejos-ftp-storage"
  acl    = "private"
}

# Grupo de seguridad para FTP
resource "aws_security_group" "ftp_security_group" {
  vpc_id = aws_vpc.vpc1.id
  name   = "ftp_security_group"

  ingress {
    from_port   = 20
    to_port     = 20
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 1100
    to_port     = 1100
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 1101
    to_port     = 1101
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia bastionada (solo accesible por una IP)
resource "aws_security_group" "bastion_security_group" {
  vpc_id = aws_vpc.vpc1.id
  name   = "bastion_security_group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia FTP
resource "aws_instance" "instancia-ftp" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.vpc1_public_subnet.id
  vpc_security_group_ids = [aws_security_group.ftp_security_group.id]
  key_name               = var.key_name
  user_data              = file(var.user_data)
  tags = {
    Name = "InstanciaFTP"
  }
}

# Instancia Bastion
resource "aws_instance" "instancia_bastion" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.vpc1_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  key_name               = var.key_name
  user_data              = file(var.user_data)
  tags = {
    Name = "InstanciaBastion"
  }
}
