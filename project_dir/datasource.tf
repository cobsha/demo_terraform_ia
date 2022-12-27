data "aws_acm_certificate" "amazon_issued" {

  domain      = "*.cobbtech.site"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_ami" "ami" {

  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["${var.project}-${var.env}-backend-*"]
  }

}