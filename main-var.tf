provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "MainVPC" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = { Name = "PublicSubnet" }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  tags = { Name = "PrivateSubnet" }
}

resource "aws_security_group" "allow_ssh_https" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "AllowSSHAndHTTPS" }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("C:/Users/sony/.ssh/id_rsa.pub") # Update path to your actual public key
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh_https.id]
  key_name               = aws_key_pair.deployer.key_name

  tags = { Name = "WebServer" }
}

output "instance_public_ip" {
  description = "Public IP of the created EC2 instance"
  value       = aws_instance.web.public_ip
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the created Public Subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the created Private Subnet"
  value       = aws_subnet.private.id
}

output "security_group_id" {
  description = "The ID of the created Security Group"
  value       = aws_security_group.allow_ssh_https.id
}

output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.web.id
}
