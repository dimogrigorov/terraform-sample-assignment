output "subnet" {
    value = aws_subnet.assignment-subnet
}

output "private_rt" {
    value = aws_route_table.private-rt
}

output "public_rt" {
    value = aws_route_table.public-rt
}