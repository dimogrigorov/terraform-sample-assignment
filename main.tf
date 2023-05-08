provider "aws" {
  region = "eu-west-1"
}
# internet gateway
resource "aws_internet_gateway" "internet-gw" {
    vpc_id = aws_vpc.assignment-vpc.id
    tags = {
        Name = "internet-gw"
    }
}

module "myassignment-private-subnet" {
  source = "./modules/isolated_subnet"
  cidr_block = var.private_subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.assignment-vpc.id
  int_gateway_id = aws_internet_gateway.internet-gw.id
  map_public_ip_on_launch = "false"
  name_tag = "private"
  route_table_id = module.myassignment-private-subnet.private_rt.id
}

module "myassignment-public-subnet" {
  source = "./modules/isolated_subnet"
  cidr_block = var.public_subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.assignment-vpc.id
  int_gateway_id = aws_internet_gateway.internet-gw.id
  map_public_ip_on_launch = "true"
  name_tag = "public"
  route_table_id = module.myassignment-public-subnet.public_rt.id
}

module "my-assignment-web-server" {
  source = "./modules/http_server"
  subnet_id = module.myassignment-private-subnet.subnet.id
  number_of_instances = 3
  public_key_location = var.public_key_location
  image_reg_name = var.image_reg_name
  vpc_id = aws_vpc.assignment-vpc.id
  my_ip = var.my_ip
  cidr_block = var.vpc_cidr_block
  avail_zone = var.avail_zone
  instance_type = var.instance_type
  env_prefix = var.env_prefix
}

resource "aws_vpc" "assignment-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}
