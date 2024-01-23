terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.credentials.access_key
  secret_key = var.credentials.secret_key
}
resource "aws_vpc" "project_3_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Project 3 VPC"
  }
}

resource "aws_subnet" "prject_3_subnet" {
  vpc_id     = aws_vpc.project_3_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Project 3 Subnet"
  }
}

resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.project_3_vpc.id
  tags = {
    Name = "Project 3 IGW"
  }
}

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

resource "aws_route_table_association" "public_rt_association_igw" {
  subnet_id      = aws_subnet.prject_3_subnet.id
  route_table_id = aws_route_table.project_3_RT.id
}

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
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Public Security Group"
  }
}

resource "aws_key_pair" "WCD_project_2_key" {
  key_name   = "WCD_project_3_key"
  public_key = file("~/.ssh/id_rsa.pub")
}
