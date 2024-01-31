terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

# AWS Access Credentials.
provider "aws" {
  region     = "us-east-1"
  access_key = var.credentials.access_key
  secret_key = var.credentials.secret_key
}

# Create AWS VPC.
resource "aws_vpc" "project_3_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Project 3 VPC"
  }
}

#Create Subnet for VPC above.
resource "aws_subnet" "project_3_subnet" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.project_3_vpc.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "Project 3 Subnet"
  }
}

# Create Internet Gateway.
resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.project_3_vpc.id
  tags = {
    Name = "Project 3 IGW"
  }
}

# Route Table to IGW.
resource "aws_route_table" "project_3_RT" {
  vpc_id = aws_vpc.project_3_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }
  tags = {
    Name = "Project 3 RT"
  }
}

# Public Subnet association with IGW Route Table.
resource "aws_route_table_association" "public_rt_association_igw" {
  subnet_id      = aws_subnet.project_3_subnet.id
  route_table_id = aws_route_table.project_3_RT.id
}

# Security group for EC2 Instance .
resource "aws_security_group" "public_security_group" {
  vpc_id = aws_vpc.project_3_vpc.id
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Public Security Group"
  }
}

# Security Key.
resource "aws_key_pair" "WCD_project_3_key" {
  key_name   = "WCD_project_3_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# EC2 Instance for Web App.
resource "aws_instance" "project_3_instance" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.project_3_subnet.id
  vpc_security_group_ids      = [aws_security_group.public_security_group.id]
  key_name                    = aws_key_pair.WCD_project_3_key.key_name
  associate_public_ip_address = true
  user_data                   = file("setup.sh")
  tags = {
    Name = "Project 3 Website Server"
  }
}