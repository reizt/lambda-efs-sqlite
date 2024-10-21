resource "aws_lambda_layer_version" "this" {
  layer_name               = local.app
  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["x86_64"]
  s3_bucket                = data.aws_s3_bucket.this.bucket
  s3_key                   = data.aws_s3_object.layer.key
  s3_object_version        = data.aws_s3_object.layer.version_id
}

resource "aws_security_group" "lambda" {
  name   = "${local.app}-lambda"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  efs_mount_path = "/mnt/efs"
}

module "lambda" {
  source  = "../../modules/lambda"
  name    = local.app
  runtime = "python3.12"
  handler = "lambda.handler"
  layers  = [aws_lambda_layer_version.this.arn]
  environment = {
    DATABASE_URL = "${local.efs_mount_path}/sqlite3.db"
  }
  s3_bucket              = data.aws_s3_object.source.bucket
  s3_key                 = data.aws_s3_object.source.key
  s3_object_version      = data.aws_s3_object.source.version_id
  policy                 = data.aws_iam_policy_document.lambda.json
  subnet_ids             = [var.subnet_id]
  security_group_ids     = [aws_security_group.lambda.id]
  file_system_arn        = aws_efs_access_point.this.arn
  file_system_mount_path = local.efs_mount_path
  log_group_name         = "/${local.app}/lambda"

  depends_on = [aws_efs_mount_target.this]
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]
    resources = [
      aws_efs_access_point.this.arn,
    ]
  }
}
