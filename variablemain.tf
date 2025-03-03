
provider "aws" {
  region = var.default_region
}

resource "aws_vpc" "test_vpc" {
  cidr_block = var.vpc_block
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = var.subnet_block
  availability_zone = var.availability_zone
  tags = {
    Name = var.subnet_name
  }
}

resource "aws_security_group" "test_sg" {
  name = var.security_groups_group_name
  description = var.security_groups_desc
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = var.security_groups_name
  }
  ingress {
    from_port = var.ssh_port
    to_port = var.ssh_port
    protocol = var.protocol
    cidr_blocks = var.traffic_from_anywhere
  }

    ingress {  #allowing http port
    from_port = var.http_port
    to_port = var.http_port
    protocol = var.protocol
    cidr_blocks = var.traffic_from_anywhere #from anywhere
    }

    egress{
    from_port = var.to_from_port
    to_port = var.to_from_port
    protocol = var.any_protocol #  any port
    cidr_blocks = var.traffic_from_anywhere # anywhere
  }
}

resource "aws_key_pair" "test_key_pair" {
  key_name = var.key_name
  public_key = "${file("terraform.ec2.pub")}"
  tags = {
    Name = var.key_pair_name
  }
}
resource "aws_instance" "test1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.test_subnet.id
  security_groups = [aws_security_group.test_sg.id]
  availability_zone = aws_subnet.test_subnet.availability_zone
  #tags = {
  # Name = var.instance_name  #this will be name of the ec2 instance
  #}

  tags = local.common_tags
  
}

locals {
  common_tags = {
    name = "team-instance"
    team = "developer"
    BU = "devops"
    creation_date = "date-${formatdate("DDMMYYYY", timestamp())}"
  }
}
