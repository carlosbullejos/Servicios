provider "aws" {
  region = var.aws_region
}

# VPC 1 con subred pública y privada
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc1_cidr_block
}

resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_subnet" "vpc1_public_subnet" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.vpc1_public_subnet_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "vpc1_private_subnet" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.vpc1_private_subnet_cidr
  availability_zone = var.availability_zone1
}

# VPC 2 con subred privada
resource "aws_vpc" "vpc2" {
  cidr_block = var.vpc2_cidr_block
}

resource "aws_subnet" "vpc2_private_subnet" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = var.vpc2_private_subnet_cidr
  availability_zone = var.availability_zone1
}

# Peering entre VPCs
resource "aws_vpc_peering_connection" "vpc1_vpc2_peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true
}

# Tabla de rutas para el tráfico de internet en la subred pública de VPC 1
resource "aws_route_table" "vpc1_public_route_table" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }
}

resource "aws_route_table_association" "vpc1_public_route_assoc" {
  subnet_id      = aws_subnet.vpc1_public_subnet.id
  route_table_id = aws_route_table.vpc1_public_route_table.id
}

# Tabla de rutas privada en VPC 1
resource "aws_route_table" "vpc1_private_route_table" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_route_table_association" "vpc1_private_route_assoc" {
  subnet_id      = aws_subnet.vpc1_private_subnet.id
  route_table_id = aws_route_table.vpc1_private_route_table.id
}

# Tabla de rutas privada en VPC 2
resource "aws_route_table" "vpc2_private_route_table" {
  vpc_id = aws_vpc.vpc2.id
}

resource "aws_route_table_association" "vpc2_private_route_assoc" {
  subnet_id      = aws_subnet.vpc2_private_subnet.id
  route_table_id = aws_route_table.vpc2_private_route_table.id
}

# Rutas de peering entre VPCs usando recursos aws_route separados

# Ruta en VPC 1 para llegar a VPC 2
resource "aws_route" "route_vpc1_to_vpc2" {
  route_table_id           = aws_route_table.vpc1_public_route_table.id
  destination_cidr_block   = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2_peering.id
}

# Ruta en VPC 2 para llegar a VPC 1
resource "aws_route" "route_vpc2_to_vpc1" {
  route_table_id           = aws_route_table.vpc2_private_route_table.id
  destination_cidr_block   = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2_peering.id
}

# Grupos de seguridad y otras configuraciones permanecen igual...

resource "aws_security_group" "ftp_security_group" {
  vpc_id = aws_vpc.vpc1.id
  name   = "ftp_security_group"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"  # Permite ICMP para ping
    cidr_blocks = [aws_vpc.vpc1.cidr_block, aws_vpc.vpc2.cidr_block]  # Permite ping desde VPC1 y VPC2
  }

  ingress {
    from_port   = 20
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 1100
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


# Security Group para el servidor LDAP en la VPC2
resource "aws_security_group" "ldap_security_group" {
  vpc_id = aws_vpc.vpc2.id
  name   = "ldap_security_group"

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.ftp_security_group.id]
    cidr_blocks = [
      aws_vpc.vpc1.cidr_block, 
      aws_vpc.vpc2.cidr_block   
    ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port       = 389
    to_port         = 389
    protocol        = "tcp"
    security_groups = [aws_security_group.ftp_security_group.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "instancia_ftp" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.vpc1_public_subnet.id
  vpc_security_group_ids = [aws_security_group.ftp_security_group.id]
  key_name               = var.key_name
  availability_zone      = "us-east-1a"
  user_data              = file("ftp.sh")
  tags = {
    Name = "InstanciaFTP"
  }
}

# Instancia LDAP en la subred privada de VPC2
resource "aws_instance" "instancia_ldap" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.vpc2_private_subnet.id
  vpc_security_group_ids = [aws_security_group.ldap_security_group.id]
  key_name               = var.key_name
  user_data              = file("ldap.sh")
  availability_zone      = "us-east-1a"
  tags = {
    Name = "InstanciaLDAP"
  }
}

# Bastion Host
resource "aws_instance" "bastion_host" {
  ami                          = var.instance_ami
  instance_type                = var.instance_type
  subnet_id                    = aws_subnet.vpc1_public_subnet.id
  vpc_security_group_ids       = [aws_security_group.bastion_sg.id]
  key_name                     = var.key_name
  associate_public_ip_address  = true
  tags = {
    Name = "BastionHost"
  }
}
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_security_group"
  description = "Allow SSH access from a specific IP for Bastion Host"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ip]  # IP específica para acceder al bastión
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Bucket S3 para almacenamiento FTP
resource "aws_s3_bucket" "ftp_storage" {
  bucket = "my-ftp-storage-bucket"
  force_destroy = true
}


