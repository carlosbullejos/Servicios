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

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_security_group"
  description = "Allow SSH access from a specific IP for Bastion Host"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ip]  # IP específica desde donde acceder al bastión
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
  iam_instance_profile   = aws_iam_role.s3_access_role.name
  tags = {
    Name = "InstanciaFTP"
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.vpc1_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name
  associate_public_ip_address = true
  tags = {
    Name = "BastionHost"
  }
}

resource "aws_s3_bucket" "ftp_storage" {
  bucket = "my-ftp-storage-bucket"
  acl    = "private"
}

resource "aws_iam_role" "s3_access_role" {
  name = "ftp-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "ftp-s3-access-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:*"],
        Resource = ["arn:aws:s3:::${aws_s3_bucket.ftp_storage.bucket}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

