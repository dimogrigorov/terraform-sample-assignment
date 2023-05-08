
resource "aws_subnet" "assignment-subnet" {
  vpc_id = var.vpc_id
  cidr_block = var.cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-${var.name_tag}-subnet"
  }
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

# Public routes
resource "aws_route_table" "public-rt" {
    vpc_id = var.vpc_id
    
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = var.int_gateway_id
    }
    
    tags = {
      Name: "${var.env_prefix}-public-rt"
    }
}
# Private routes
resource "aws_route_table" "private-rt" {
    vpc_id = var.vpc_id
    
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gateway.id
    }
    
    tags = {
      Name: "${var.env_prefix}-private-rt"
    }
}
resource "aws_eip" "nat_gateway" {
    vpc = true
}
# nat gateway
resource "aws_nat_gateway" "nat-gateway" {
    allocation_id = aws_eip.nat_gateway.id
    subnet_id     = aws_subnet.assignment-subnet.id
    # To ensure proper ordering, add Internet Gateway as dependency
    //depends_on = [aws_internet_gateway.internet-gw]
}
resource "aws_route_table_association" "rta" {
  subnet_id = aws_subnet.assignment-subnet.id
  route_table_id = var.route_table_id
 }