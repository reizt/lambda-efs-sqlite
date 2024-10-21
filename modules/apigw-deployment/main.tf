variable "rest_api_id" {
  type = string
}
variable "log_group_name" {
  type = string
}
output "stage_name" {
  value = aws_api_gateway_stage.main.stage_name
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.rest_api_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name = var.log_group_name
}

resource "aws_api_gateway_stage" "main" {
  rest_api_id   = var.rest_api_id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = "main"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode({
      requestId               = "$context.requestId",
      ip                      = "$context.identity.sourceIp",
      user                    = "$context.identity.user",
      userAgent               = "$context.identity.userAgent",
      status                  = "$context.status",
      method                  = "$context.httpMethod",
      path                    = "$context.path",
      resourcePath            = "$context.resourcePath",
      latency                 = "$context.requestTime",
      integrationErrorMessage = "$context.integrationErrorMessage",
      errorMessage            = "$context.error.message",
      errorResponseType       = "$context.error.responseType",
    })
  }
}
