data "aws_lambda_layer_version" "this" {
  for_each   = toset(var.layers)
  layer_name = each.value
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  role             = module.lambda_role.role_arn
  timeout          = 900
  memory_size      = 10240
  package_type     = "Zip"
  runtime          = var.runtime
  handler          = var.handler
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  source_code_hash = var.source_code_hash
  layers = [
    for layer in data.aws_lambda_layer_version.this : layer.arn
  ]
  environment {
    variables = var.environment
  }
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  file_system_config {
    arn              = var.file_system_arn
    local_mount_path = var.file_system_mount_path
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.name}"
}

module "lambda_role" {
  source             = "../iam-role"
  role_name          = "${var.name}-lambda"
  policy_name        = "${var.name}-lambda"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  policy             = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  source_policy_documents = [
    var.policy,
  ]
  statement {
    sid = "AllowLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.this.arn,
      "${aws_cloudwatch_log_group.this.arn}:*",
    ]
  }
  statement {
    sid = "AllowENI"
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
    ]
    resources = ["*"]
  }
}
