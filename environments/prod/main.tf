provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "nonprod" {
  backend = "s3"

  config = {
    bucket = "acs730-huy-terraform-state-2026"
    key    = "nonprod/terraform.tfstate"
    region = var.aws_region
  }
}

module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = []
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  create_internet_gateway = false
  create_nat_gateway      = false
}

module "ec2" {
  source = "../../modules/ec2"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  owner_name    = var.owner_name

  bastion_security_group_id = data.terraform_remote_state.nonprod.outputs.bastion_security_group_id
}