# Create an ALB
resource "aws_lb" "assignment-alb" {
  name               = "${var.env_prefix}-assignment-alb"
  internal           = false
  load_balancer_type = "application"
  //security_groups  = var.my_security_group
  subnets            = var.subnets_ids
  tags = {
    Name: "${var.env_prefix}-alb"
  }
}

# Create a listener for the ALB
resource "aws_lb_listener" "web_server_https_elb_listener" {
  load_balancer_arn  = "${aws_lb.assignment-alb.arn}"
  port               = "443"
  protocol           = "HTTPS"

/*
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
*/

  ssl_policy         = "ELBSecurityPolicy-2016-08"
  //certificate_arn    = "${data.aws_acm_certificate.my-certificate.arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.assignment_ec2_targets.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "tgattachment" {
  count            = length(data.aws_instances.webserver_instances.ids)
  target_group_arn = aws_lb_target_group.assignment_ec2_targets.arn
  target_id        = element(data.aws_instances.webserver_instances.ids, count.index)
}

resource "aws_lb_target_group" "assignment_ec2_targets" {
  name        = "TargetGroup"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

/*data "aws_acm_certificate" "my-certificate" {
  domain      = "tf.example.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}*/

data "aws_instances" "webserver_instances" {
  instance_tags = {
     Marker: "MyWebAppInstances"
  }
  instance_state_names = ["running"]
}

# Request and validate an SSL certificate from AWS Certificate Manager (ACM)
/*resource "aws_acm_certificate" "my-certificate" {
  domain_name       = "example.com"
  validation_method = "DNS"

  tags = {
    Name = "example.com SSL certificate"
  }
}

# Associate the SSL certificate with the ALB listener
resource "aws_lb_listener_certificate" "my-certificate" {
  listener_arn = aws_lb_listener.web_server_https_elb_listener.arn
  certificate_arn = aws_acm_certificate.my-certificate.arn
}
*/