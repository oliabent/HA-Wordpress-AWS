terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
  }
  backend "s3" {
    bucket = "tf-state-prod-obent"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = local.region
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

locals {
  region  = "eu-west-1"
  env     = "dev"
  app     = "wordpress"
  keys    = "EC2 Tutorial"
  db_user = "wordpressuser"
}