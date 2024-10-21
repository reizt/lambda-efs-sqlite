variable "app" {
  type = string
}
locals {
  app = var.app
}

variable "lambda_name" {
  type = string
}
variable "lambda_invoke_arn" {
  type = string
}

module "apigw" {
  source = "../../modules/apigw"
  name   = local.app
}

module "apigw_lambda_proxy" {
  source                 = "../../modules/apigw-lambda-proxy"
  rest_api_id            = module.apigw.rest_api_id
  rest_api_execution_arn = module.apigw.execution_arn
  parent_resource_id     = module.apigw.root_resource_id
  method                 = "POST"
  path                   = "{proxy+}"
  header_mappings        = []
  lambda_name            = var.lambda_name
  lambda_invoke_arn      = var.lambda_invoke_arn
}

module "apigw_deployment" {
  source         = "../../modules/apigw-deployment"
  rest_api_id    = module.apigw.rest_api_id
  log_group_name = "${local.app}/apigw"
  depends_on = [
    module.apigw_lambda_proxy,
  ]
}

data "aws_acm_certificate" "this" {
  domain = "reij.uno"
}

module "apigw_domain" {
  source          = "../../modules/apigw-domain"
  rest_api_id     = module.apigw.rest_api_id
  stage_name      = module.apigw_deployment.stage_name
  domain_name     = "les.reij.uno"
  certificate_arn = data.aws_acm_certificate.this.arn
}
