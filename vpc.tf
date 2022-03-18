module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.13.0"

  name = "${local.env}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
}

module "security_group_mysql" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name   = "${local.app}-${local.env}-mysql-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.security_group_instances.security_group_id
    },
  ]
}

module "security_group_lb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name   = "${local.app}-${local.env}-lb-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  egress_rules = ["all-all"]
}

module "security_group_instances" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name   = "${local.app}-${local.env}-asg-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.security_group_lb.security_group_id
    },
  ]
  egress_rules = ["all-all"]
}