module "vpc" {
  source = "./module/vpc"
}

module "cw" {
  source   = "./module/cw"
  instance = module.ec2.instance
  region   = data.aws_region.current.name
  host     = module.ec2.host
  lambda   = module.lambda.arn
}

module "iam" {
  source    = "./module/iam"
  log_group = module.cw.lambda_cw_arn
}

module "ec2" {
  source           = "./module/ec2"
  ami              = data.aws_ami.ec2.id
  sg               = module.vpc.ec2_sg
  instance_profile = module.iam.instance_profile
  log_group        = module.cw.ec2_cw
}

module "lambda" {
  source    = "./module/lambda"
  role      = module.iam.lambda_role
  region    = data.aws_region.current.name
  log_group = module.cw.lambda_cw
  instance  = module.ec2.instance
}
