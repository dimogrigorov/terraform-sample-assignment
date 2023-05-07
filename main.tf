provider "aws" {
  region = "eu-west-1"
}

module "myassignment-subnet" {
  source = "./modules/isolated_subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.assignment-vpc.id
}

resource "aws_vpc" "assignment-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_security_group" "my-assignment-sg" {
  name = "my-assignment-sg"
  vpc_id = aws_vpc.assignment-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name: "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "my-ec2-instance" {
  ami = data.aws_ami.latest-amazon-image.id
  instance_type = var.instance_type
  subnet_id = module.myassignment-subnet.subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my-assignment-sg.id]
  availability_zone = var.avail_zone
  key_name = var.key-pair
    tags = {
    Name: "${var.env_prefix}-ec2"
  }
  user_data = file("docker-script.sh")
}