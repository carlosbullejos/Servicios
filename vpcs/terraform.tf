provider "aws" {
  region = "us-east-1"
}

# VPC1
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "vpc1_public_subnet" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "vpc1_private_subnet" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

# VPC2
resource "aws_vpc" "vpc2" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "vpc2_private_subnet" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1b"
}

# VPC Peering
resource "aws_vpc_peering_connection" "vpc1_vpc2_peering" {
  vpc_id        = aws_vpc.vpc1.id
  peer_vpc_id   = aws_vpc.vpc2.id
  auto_accept   = true
}

# Route tables for VPC1 subnets
resource "aws_route_table" "vpc1_public_route_table" {
  vpc_id = aws_vpc.vpc1.id
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

# Route tables for VPC2 private subnet
resource "aws_route_table" "vpc2_private_route_table" {
  vpc_id = aws_vpc.vpc2.id
}

resource "aws_route_table_association" "vpc2_private_route_assoc" {
  subnet_id      = aws_subnet.vpc2_private_subnet.id
  route_table_id = aws_route_table.vpc2_private_route_table.id
}

# Routes for Peering
resource "aws_route" "route_vpc1_to_vpc2" {
  route_table_id         = aws_route_table.vpc1_private_route_table.id
  destination_cidr_block = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2_peering.id
}

resource "aws_route" "route_vpc2_to_vpc1" {
  route_table_id         = aws_route_table.vpc2_private_route_table.id
  destination_cidr_block = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2_peering.id
}
