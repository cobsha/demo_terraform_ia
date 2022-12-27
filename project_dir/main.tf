module "vpc" {

  source   = "../module/vpc"
  vpc_cidr = var.cidr
  project  = var.project
  env      = var.env
  region   = var.region
}

module "alb" {

  source              = "../module/alb"
  vpc_id              = module.vpc.vpc.id
  subnet_ids          = module.vpc.public_subnet
  project             = var.project
  env                 = var.env
  acm_certificate_arn = data.aws_acm_certificate.amazon_issued.arn
  domain              = var.domain

}

module "asg" {
  
  source = "../module/asg"
  project = var.project
  env = var.env
  image_id = data.aws_ami.ami.id
  instance_type = var.instance_type
  target_group_arn = module.alb.tg.arn
  vpc_id = module.vpc.vpc.id
  subnet_ids = module.vpc.private_subnet
}

/* resource "aws_key_pair" "deployer" {

  key_name   = "${var.project}-${var.env}"
  public_key = file("auth_key.pub")
  tags = {
    Name    = "${var.project}-${var.env}"
    project = var.project
    env     = var.env
  }
}

resource "aws_ebs_volume" "app" {

  availability_zone = "${var.region}a"
  size              = 5

  tags = {
    Name    = "${var.project}-${var.env}-vol"
    project = var.project
    env     = var.env
  }
}

resource "aws_volume_attachment" "ebs_att" {

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.app.id
  instance_id = aws_instance.instance.id
}


resource "aws_security_group" "ec2-sg" {

  name_prefix = "${var.project}-"
  description = "uk-POC backend instance security group"
  vpc_id      = module.vpc.vpc.id

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

resource "aws_instance" "instance" {

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = module.vpc.private_subnet[0]
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  tags = {
    Name    = "${var.project}-${var.env}-backend"
    project = var.project
    env     = var.env
  }
}
 */

