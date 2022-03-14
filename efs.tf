module "efs" {
  source                     = "cloudposse/efs/aws"
  version                    = "0.32.6"
  name                       = "wordpress-nfs"
  region                     = var.region
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.private_subnets
  allowed_security_group_ids = [module.vpc.default_security_group_id]
}


