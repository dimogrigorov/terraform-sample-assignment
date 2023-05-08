provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "assignment-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
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
  avail_zone = var.avail_zone_a
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.assignment-vpc.id
  int_gateway_id = aws_internet_gateway.internet-gw.id
  map_public_ip_on_launch = "false"
  name_tag = "private"
  route_table_id = module.myassignment-private-subnet.private_rt.id
}

module "public-subnet-A" {
  source = "./modules/isolated_subnet"
  cidr_block = var.public_subnet_cidr_block
  avail_zone = var.avail_zone_a
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.assignment-vpc.id
  int_gateway_id = aws_internet_gateway.internet-gw.id
  map_public_ip_on_launch = "true"
  name_tag = "public"
  route_table_id = module.public-subnet-A.public_rt.id
}

module "public-subnet-B" {
  source = "./modules/isolated_subnet"
  cidr_block = var.public_subnet_cidr_block_b
  avail_zone = var.avail_zone_b
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.assignment-vpc.id
  int_gateway_id = aws_internet_gateway.internet-gw.id
  map_public_ip_on_launch = "true"
  name_tag = "public"
  route_table_id = module.public-subnet-B.public_rt.id
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
  avail_zone = var.avail_zone_a
  instance_type = var.instance_type
  env_prefix = var.env_prefix
}

module "my-assignment-alb" {
  source = "./modules/alb"
  subnets_ids = [module.public-subnet-A.subnet.id, module.public-subnet-B.subnet.id]
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.assignment-vpc.id
}