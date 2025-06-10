module "vpc" { 
    source = "../../modules/vpc"
    name=var.name
    vpc_cidr=var.vpc_cidr
    public_subnet_cidrs=var.public_subnet_cidrs
    private_subnet_cidrs=var.private_subnet_cidrs 
}

module "alb" {
  source     = "../../modules/alb"
  name       = var.name
  vpc_id     = module.vpc.app_vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  app_port   = var.app_port
  domain_name = var.domain_name
  app_domain = var.app_domain
  
}

module "ec2_asg" {
  source            = "../../modules/ec2_asg"
  region            = var.aws_region
  vpc_id            = module.vpc.app_vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  ami               = var.ami
  key_name          = var.key_name
  instance_type     = var.instance_type
  min_size          = var.min_size
  max_size          = var.max_size
  app_port          = var.app_port
  db_port           = var.db_port
  ecr_repo          = [module.ecr.ecr]
  target_group_arns = [module.alb.target_group_arn]
}

module "rds" {
  source             = "../../modules/rds"
  name               = var.name
  engine             = var.db_engine
  instance_class     = var.db_instance_class
  allocated_storage  = var.db_allocated_storage
  db_port            = var.db_port
  username           = var.db_username
  password           = var.db_password
  variable "version" { type = string }
  private_subnet_ids = module.network.private_subnet_ids
}

module "ecr" {
  source = "../../modules/ecr"
  name = var.ecr_repo_name
}