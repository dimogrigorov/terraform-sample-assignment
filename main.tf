variable avail_zone {
  type = string
}
variable vpc_cidr_block {
  type = string
}
variable subnet_cidr_block {
  type = string
}
variable env_prefix {
  type = string
}
variable my_ip {
  type = string
}
variable "instance_type" {
  type = string
}
variable "key-pair" {
  type = string
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "assignment-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "assignment-subnet" {
  vpc_id = aws_vpc.assignment-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet"
  }
}

resource "aws_route_table" "assignment-vpc-route-table" {
  vpc_id = aws_vpc.assignment-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.int-gateway.id
  }
  tags = {
    Name: "${var.env_prefix}-rt"
  }
}

resource "aws_internet_gateway" "int-gateway" {
  vpc_id = aws_vpc.assignment-vpc.id
  tags = {
    Name: "${var.env_prefix}-gw"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id = aws_subnet.assignment-subnet.id
  route_table_id = aws_route_table.assignment-vpc-route-table.id
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

/*output "aws_ami" {
  value = data.aws_ami.latest-amazon-image
}*/

resource "aws_instance" "my-ec2-instance" {
  ami = data.aws_ami.latest-amazon-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.assignment-subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my-assignment-sg.id]
  availability_zone = var.avail_zone
  key_name = var.key-pair
    tags = {
    Name: "${var.env_prefix}-ec2"
  }
  user_data = file("docker-script.sh")
}