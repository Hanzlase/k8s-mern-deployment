module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
}

module "app_scaling" {
  source = "./modules/asg_alb"
  vpc_id = module.vpc.vpc_id
}