data "aws_ami" "latest-amazon-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_reg_name]
  }
}

resource "aws_security_group" "my-assignment-sg" {
  name = "my-assignment-sg"
  vpc_id = var.vpc_id
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
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.cidr_block}"]
    prefix_list_ids = []
  }

  tags = {
    Name: "${var.env_prefix}-sg"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server_key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "my-ec2-instance" {
  count = var.number_of_instances
  ami = data.aws_ami.latest-amazon-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  //associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.my-assignment-sg.id]
  availability_zone = var.avail_zone
  key_name = aws_key_pair.ssh-key.key_name
  user_data = file("./modules/http_server/docker-script.sh")
  tags = {
    Name: "${var.env_prefix}-instance${count.index}-ec2"
    Marker: "MyWebAppInstances"
  }
}