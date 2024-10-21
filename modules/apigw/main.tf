variable "name" {
  type = string
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}
output "arn" {
  value = aws_api_gateway_rest_api.this.arn
}
output "root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}
output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}

resource "aws_api_gateway_rest_api" "this" {
  name = var.name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = data.aws_iam_policy_document.api_execute_policy.json
}

data "aws_iam_policy_document" "api_execute_policy" {
  statement {
    actions = [
      "execute-api:Invoke",
    ]
    resources = [
      aws_api_gateway_rest_api.this.execution_arn,
      "${aws_api_gateway_rest_api.this.execution_arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
