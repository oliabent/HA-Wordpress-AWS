terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0" #"~> 3.27" 
    }
  }
  backend "s3" {
    bucket = "tf-state-prod-obent"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.region
}