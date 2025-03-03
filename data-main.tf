data "aws_ami" "dynamic_ami" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

   filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "web" {
  ami =   data.aws_ami.dynamic_ami.id
  instance_type = "t2.micro"
}

output "ami" {
  value = data.aws_ami.dynamic_ami.id
}
