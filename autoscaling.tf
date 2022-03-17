module "asg" {
  source                    = "terraform-aws-modules/autoscaling/aws"
  version                   = "5.2.0"
  name                      = "wordpress"
  vpc_zone_identifier       = module.vpc.private_subnets
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  create_scaling_policy     = false

  image_id         = "ami-0db188056a6ff81ae"
  instance_type    = "t2.micro"
  key_name         = "EC2 Tutorial" #Should be created before
  security_groups  = [module.security_group_mysql.security_group_id, module.efs.security_group_id, module.security_group_instances.security_group_id]
  user_data_base64 = base64encode(data.template_file.config.rendered)

  depends_on = [
    module.efs
  ]
}

data "template_file" "config" {
  template = file("wordpress_template.tpl")
  vars = {
    MOUNT_TARGET_IP1 = module.efs.mount_target_ips[0]
    MOUNT_TARGET_IP2 = module.efs.mount_target_ips[1]
    DB_HOST          = module.db.db_instance_address
    DB_NAME          = module.db.db_instance_name
    DB_USER          = module.db.db_instance_username
    DB_PASSWORD      = module.db.db_instance_password
  }
}

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