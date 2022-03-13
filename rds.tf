module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier           = "wordpress" #"wordpress-dev-mysql-multiaz"
  version              = "4.2.0"
  engine               = "mysql"
  engine_version       = "5.7.25"   #"8.0.27"
  family               = "mysql5.7" # optional?
  major_engine_version = "5.7"      # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "wordpress"
  username = "wordpressuser"
  port     = 3306

  multi_az               = true
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group.security_group_id]

  backup_retention_period = 3
  skip_final_snapshot     = true
  deletion_protection     = false


  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]
}
