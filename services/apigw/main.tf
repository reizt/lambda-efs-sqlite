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
  method                 = "ANY"
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

locals {
  root_domain_name = "reij.uno"
  api_domain_name  = "les.reij.uno"
}

data "aws_acm_certificate" "this" {
  domain = local.root_domain_name
}

module "apigw_domain" {
  source          = "../../modules/apigw-domain"
  rest_api_id     = module.apigw.rest_api_id
  stage_name      = module.apigw_deployment.stage_name
  domain_name     = local.api_domain_name
  certificate_arn = data.aws_acm_certificate.this.arn
}

data "aws_route53_zone" "this" {
  name = local.root_domain_name
}

resource "aws_route53_record" "apigw" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.api_domain_name
  type    = "A"
  alias {
    zone_id                = module.apigw_domain.regional_zone_id
    name                   = module.apigw_domain.regional_domain_name
    evaluate_target_health = true
  }
}
