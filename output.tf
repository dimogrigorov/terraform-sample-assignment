output "aws_ami" {
  value = data.aws_ami.latest-amazon-image.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.my-ec2-instance.public_ip
}