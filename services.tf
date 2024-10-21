locals {
  app = "lambda-efs-sqlite"
}

module "network" {
  source = "./services/network"
  app    = local.app
}

module "lambda" {
  source     = "./services/lambda"
  app        = local.app
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.subnet_ids
}
