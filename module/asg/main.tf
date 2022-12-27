resource "aws_security_group" "ec2-sg" {

  name_prefix = "${var.project}-"
  description = "uk-POC backend instance security group"
  vpc_id      = var.vpc_id

  ingress {

    description = "http public access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    description = "ssh public access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name    = "${var.project}-${var.env}-instance-sg"
    project = var.project
    env     = var.env
  }
}

resource "aws_launch_template" "tmplt" {

  name_prefix   = "${var.env}-"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  lifecycle {

    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {

  name_prefix = "${var.env}-"
  vpc_zone_identifier = var.subnet_ids
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  default_cooldown = 180
  health_check_grace_period = 120
  health_check_type = "EC2"
  target_group_arns = [var.target_group_arn]

  launch_template {

    id      = aws_launch_template.tmplt.id
    version = "$Latest"
  }

tag {

    key = "Name"
    value = "${var.project}-${var.env}"
    propagate_at_launch = true
}
}

resource "aws_key_pair" "key" {

  key_name   = "${var.project}-${var.env}-key"
  public_key = file("auth_key.pub")
  tags = {

    name = "${var.project}-key"
    project = var.project
    env = var.env
  }
}