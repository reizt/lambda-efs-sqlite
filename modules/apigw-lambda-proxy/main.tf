variable "rest_api_id" {
  type = string
}
variable "rest_api_execution_arn" {
  type = string
}
variable "parent_resource_id" {
  type = string
}
variable "method" {
  type = string
}
variable "path" {
  type = string
}
variable "header_mappings" {
  type = list(object({
    from     = string
    to       = string
    required = bool
  }))
}
variable "lambda_name" {
  type = string
}
variable "lambda_invoke_arn" {
  type = string
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = var.method
  authorization = "NONE"
  request_parameters = {
    for header in var.header_mappings :
    "method.request.header.${header.from}" => header.required
  }
}

resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn

  request_parameters = {
    for header in var.header_mappings :
    "integration.request.header.${header.to}" => "method.request.header.${header.from}"
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.rest_api_execution_arn}/*/*/*"
}
