// Root Terraform configuration: composes smaller modules to build the environment.

// VPC module: creates network, subnets, and NAT gateway.
module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  private_subnet_id = module.vpc.private_subnet_ids[0] # Add this line
}

// Temporarily disable this broken module until Task 7
# module "app_scaling" {
#   source = "./modules/asg_alb"
# }

// Assignment 4: Jenkins CI/CD Infrastructure
module "jenkins" {
  source            = "../assignment-4/jenkins" 
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_ids[0]  
  private_subnet_id = module.vpc.private_subnet_ids[0] 
  key_name          = "assignment3-key"      
}