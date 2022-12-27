resource "aws_security_group" "alb_sg" {

  name_prefix = "${var.project}-sg-"
  description = "Allow TLS and HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS traaffic from outside"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP traffic from outside"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  lifecycle {

    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-alb-sg"
    project = var.project
    env = var.env
  }
}

resource "aws_lb_target_group" "tg" {
  
  name_prefix = "${var.env}-"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  deregistration_delay = 120
  health_check {
    
    protocol = "HTTP"
    path = "/"
    matcher = 200
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  tags = {

    project = var.project
    env = var.env
  }
  lifecycle {

    create_before_destroy = true
  }
}

resource "aws_lb" "lb" {

  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.alb_sg.id ]
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.project}-alb"
    project = var.project
    env = var.env
  }
}

resource "aws_lb_listener" "httpslistener" {

  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {

    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Site not found!</h1>"
      status_code  = "503"
    }
  }
  tags = {

    project = var.project
  }
}

resource "aws_lb_listener" "httplistener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "rule" {
  
  listener_arn = aws_lb_listener.httpslistener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = [var.domain]
    }
  }
}