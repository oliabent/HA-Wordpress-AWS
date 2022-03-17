module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "6.8.0"
  name               = "wordpress-dev-elb"
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
    ####### TODO: HTTPS listener, HTTP listener which redirect trafic to HTTPS
  ]

  target_groups = [
    {
      name_prefix      = "tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = data.aws_instances.asg.ids[0]
          port      = 80
        },
        {
          target_id = data.aws_instances.asg.ids[1]
          port      = 80
        }
      ]
    }
  ]

  depends_on = [
    module.asg
  ]
}

resource "time_sleep" "wait_60_seconds" {
  depends_on      = [module.asg]
  create_duration = "60s"
}

data "aws_instances" "asg" {
  filter {
    name   = "instance.group-id"
    values = [module.security_group_instances.security_group_id]
  }

  depends_on = [time_sleep.wait_60_seconds]
}
