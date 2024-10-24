locals {
  app = "les"
}

module "network" {
  source = "./services/network"
  app    = local.app
}

module "lambda" {
  source    = "./services/lambda"
  app       = local.app
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.public_subnet_id
}

module "apigw" {
  source             = "./services/apigw"
  app                = local.app
  lambda_names       = module.lambda.names
  lambda_invoke_arns = module.lambda.invoke_arns
}

module "gha" {
  source      = "./services/gha"
  app         = local.app
  lambda_arns = [for key, arn in module.lambda.arns : arn]
}
