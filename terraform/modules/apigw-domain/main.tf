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
variable "base_path" {
  type = string
}

output "regional_domain_name" {
  value = aws_api_gateway_domain_name.this.regional_domain_name
}
output "regional_zone_id" {
  value = aws_api_gateway_domain_name.this.regional_zone_id
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = var.rest_api_id
  domain_name = aws_api_gateway_domain_name.this.domain_name
  stage_name  = var.stage_name
  base_path   = var.base_path
}
