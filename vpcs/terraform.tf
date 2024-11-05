provider "aws" {
  region = var.aws_region
}

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

resource "aws_vpc" "vpc2" {
  cidr_block = var.vpc2_cidr_block
}

resource "aws_subnet" "vpc2_private_subnet" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = var.vpc2_private_subnet_cidr
  availability_zone = var.availability_zone2
}

resource "aws_vpc_peering_connection" "vpc1_vpc2_peering" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true
}

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

resource "aws_route_table" "vpc1_private_route_table" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_route_table_association" "vpc1_private_route_assoc" {
  subnet_id      = aws_subnet.vpc1_private_subnet.id
  route_table_id = aws_route_table.vpc1_private_route_table.id
}

resource "aws_route_table" "vpc2_private_route_table" {
  vpc_id = aws_vpc.vpc2.id
}

resource "aws_route_table_association" "vpc2_private_route_assoc" {
  subnet_id      = aws_subnet.vpc2_private_subnet.id
  route_table_id = aws_route_table.vpc2_private_route_table.id
}

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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
