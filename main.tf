terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "terraform_vpc"{
  cidr_block            = "10.0.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "terraform_vpc"
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform_igw"
  }
}

resource "aws_subnet" "terraform_subnet" {
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform_subnet"
  }
}

resource "aws_route_table" "terraform_route_table" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }

  tags = {
    Name = "terraform_route_table"
  }
}

resource "aws_route_table_association" "terraform_rta" {
  subnet_id = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terraform_route_table.id
}

resource "aws_security_group" "terraform_sg" {
  name = "terraform_sg"
  description = "HTTP and SSH"
  vpc_id = aws_vpc.terraform_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_sg"
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.terraform_subnet.id
  
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]

  tags = {
    Name = var.instance_name
  }
}