module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.5.0"

  name = "bastionhost"

  ami                    = "ami-0db188056a6ff81ae"
  instance_type          = "t2.micro"
  key_name               = "EC2 Tutorial"
  vpc_security_group_ids = [module.security_group_bastion.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

}


module "security_group_bastion" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_rules = ["all-all"]
}