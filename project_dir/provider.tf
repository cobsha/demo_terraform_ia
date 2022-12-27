provider "aws" {

  profile = var.profile
  region = var.region
}

terraform {

  backend "s3" {
    bucket = "proton-shafi-terraform-backend"
    key    = "ia_backend/state.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    profile = "shafi-proton"
  }
}
