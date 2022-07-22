module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "6.8.0"
  name               = "${local.app}-${local.env}-elb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  security_groups    = [module.security_group_lb.security_group_id]
  subnets            = module.vpc.public_subnets

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = "${local.app}-${local.env}-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]
}

module "asg" {
  source                    = "terraform-aws-modules/autoscaling/aws"
  version                   = "5.2.0"
  name                      = "${local.app}-${local.env}-asg"
  vpc_zone_identifier       = module.vpc.private_subnets
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  create_scaling_policy     = false
  scaling_policies = {
    avg-cpu-policy-greater-than-80 = {
      policy_type               = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 80.0
      }
    }
  }
  image_id         = "ami-0db188056a6ff81ae"
  instance_type    = "t2.micro"
  key_name         = local.keys
  security_groups  = [module.security_group_mysql.security_group_id, module.efs.security_group_id, module.security_group_instances.security_group_id]
  user_data_base64 = base64encode(data.template_file.config.rendered)

  target_group_arns = module.alb.target_group_arns

  depends_on = [
    module.efs
  ]
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier           = "${local.app}-${local.env}-mysql-multiaz"
  version              = "4.2.0"
  engine               = "mysql"
  engine_version       = "5.7.25"
  family               = "mysql5.7"
  major_engine_version = "5.7"
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = local.app
  username = local.db_user
  port     = 3306

  multi_az               = true
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.security_group_mysql.security_group_id]

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

module "efs" {
  source                     = "cloudposse/efs/aws"
  version                    = "0.32.6"
  name                       = "${local.app}-${local.env}-efs"
  region                     = local.region
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.private_subnets
  allowed_security_group_ids = [module.security_group_instances.security_group_id]
}

