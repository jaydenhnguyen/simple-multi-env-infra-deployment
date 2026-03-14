terraform {
  backend "s3" {
    bucket = "acs730-huy-terraform-state-2026"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
