# environments/prod/main.tf

module "s3" {
  source       = "../../modules/s3"
  project_name = "${var.project_name}-${var.env}"
  app_path     = "../../app"
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = "${var.project_name}-${var.env}"
  vpc_cidr     = "10.0.0.0/16"
  region       = var.region
}

module "ec2" {
  source           = "../../modules/ec2"
  project_name     = "${var.project_name}-${var.env}"
  vpc_id           = module.vpc.vpc_id
  public_subnet_1  = module.vpc.public_subnet_1
  public_subnet_2  = module.vpc.public_subnet_2
  instance_type    = var.instance_type
  min_size         = var.min_servers
  max_size         = var.max_servers
  bucket_id        = module.s3.bucket_id
  instance_profile = module.s3.instance_profile
}

module "rds" {
  source           = "../../modules/rds"
  project_name     = "${var.project_name}-${var.env}"
  vpc_id           = module.vpc.vpc_id
  private_subnet_1 = module.vpc.private_subnet_1
  private_subnet_2 = module.vpc.private_subnet_2
  web_sg_id        = module.ec2.web_sg_id
  db_password      = var.db_password
}