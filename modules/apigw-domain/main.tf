variable "certificate_arn" {
  type = string
}
variable "rest_api_id" {
  type = string
}
variable "stage_name" {
  type = string
}
variable "domain_name" {
  type = string
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = var.rest_api_id
  domain_name = aws_api_gateway_domain_name.this.domain_name
  stage_name  = var.stage_name
}
