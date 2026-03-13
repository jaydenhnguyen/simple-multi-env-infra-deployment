module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "bastion" {
  source = "../../modules/bastion"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_ids[1]

  ami_id           = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.key_name
  admin_cidr       = var.admin_cidr
}

module "ec2" {
  source = "../../modules/ec2"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.network.vpc_id
  private_subnet_ids        = module.network.private_subnet_ids
  bastion_security_group_id = module.bastion.bastion_security_group_id

  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  admin_cidr    = var.admin_cidr
  owner_name    = var.owner_name
}