// Root Terraform configuration: composes smaller modules to build the environment.

// VPC module: creates network, subnets, and NAT gateway.
module "vpc" {
  source = "./modules/vpc"
}

// EC2 module: creates a small public web server and a private instance.
// Pass the VPC ID so EC2 resources are created inside the module's VPC.
module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
}

// Auto-scaling + ALB module: manages a launch template and ASG for the app.
module "app_scaling" {
  source = "./modules/asg_alb"
  vpc_id = module.vpc.vpc_id
}