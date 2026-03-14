provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "nonprod" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "nonprod/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "prod" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "prod/terraform.tfstate"
    region = var.aws_region
  }
}

module "peering" {
  source = "../../modules/peering"

  project_name = var.project_name

  requester_vpc_id         = data.terraform_remote_state.nonprod.outputs.vpc_id
  accepter_vpc_id          = data.terraform_remote_state.prod.outputs.prod_vpc_id
  requester_vpc_cidr       = var.nonprod_vpc_cidr
  accepter_vpc_cidr        = var.prod_vpc_cidr
  requester_route_table_id = data.terraform_remote_state.nonprod.outputs.private_route_table_id
  accepter_route_table_id  = data.terraform_remote_state.prod.outputs.private_route_table_id
}
