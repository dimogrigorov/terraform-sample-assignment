
resource "aws_subnet" "assignment-subnet" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "int-gateway" {
  vpc_id = var.vpc_id
  tags = {
    Name: "${var.env_prefix}-gw"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id = aws_subnet.assignment-subnet.id
  route_table_id = aws_route_table.assignment-vpc-route-table.id
 }

resource "aws_route_table" "assignment-vpc-route-table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.int-gateway.id
  }
  tags = {
    Name: "${var.env_prefix}-rt"
  }
}