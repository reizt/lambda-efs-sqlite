variable "app" {
  type = string
}
locals {
  app  = var.app
  apps = ["python"]
}

variable "lambda_names" {
  type = map(string)
}
variable "lambda_invoke_arns" {
  type = map(string)
}

module "apigw" {
  source = "../../modules/apigw"
  name   = local.app
}

resource "aws_api_gateway_resource" "subpath" {
  for_each = toset(local.apps)

  rest_api_id = module.apigw.rest_api_id
  parent_id   = module.apigw.root_resource_id
  path_part   = each.value
}

module "apigw_lambda_proxy" {
  for_each = toset(local.apps)

  source                 = "../../modules/apigw-lambda-proxy"
  rest_api_id            = module.apigw.rest_api_id
  rest_api_execution_arn = module.apigw.execution_arn
  parent_resource_id     = aws_api_gateway_resource.subpath[each.value].id
  method                 = "ANY"
  path                   = "{proxy+}"
  header_mappings        = []
  lambda_name            = var.lambda_names[each.value]
  lambda_invoke_arn      = var.lambda_invoke_arns[each.value]
}

module "apigw_deployment" {
  source         = "../../modules/apigw-deployment"
  rest_api_id    = module.apigw.rest_api_id
  log_group_name = "/${local.app}/apigw"
  depends_on = [
    module.apigw_lambda_proxy,
  ]
}

locals {
  root_domain_name = "reij.uno"
  api_domain_names = {
    python = "les-py.reij.uno"
  }
}

data "aws_acm_certificate" "this" {
  domain = local.root_domain_name
}

module "apigw_domain" {
  for_each = toset(local.apps)

  source          = "../../modules/apigw-domain"
  rest_api_id     = module.apigw.rest_api_id
  stage_name      = module.apigw_deployment.stage_name
  domain_name     = local.api_domain_names[each.value]
  certificate_arn = data.aws_acm_certificate.this.arn
  base_path       = each.value
}

data "aws_route53_zone" "this" {
  name = local.root_domain_name
}

resource "aws_route53_record" "apigw" {
  for_each = toset(local.apps)

  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.api_domain_names[each.value]
  type    = "A"
  alias {
    zone_id                = module.apigw_domain[each.value].regional_zone_id
    name                   = module.apigw_domain[each.value].regional_domain_name
    evaluate_target_health = true
  }
}
