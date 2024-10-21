variable "app" {
  type = string
}
locals {
  app = var.app
}

variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}

resource "aws_s3_bucket" "this" {
  bucket = "crtm-lambda-efs-sqlite"
}

data "archive_file" "artifact" {
  source_dir  = "./lambda"
  type        = "zip"
  output_path = "./lambda.zip"
}

resource "aws_s3_object" "artifact" {
  bucket = aws_s3_bucket.this.bucket
  key    = "lambda.zip"
  source = data.archive_file.artifact.output_path
}

resource "aws_efs_file_system" "this" {
  creation_token = local.app
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

module "lambda" {
  source                 = "../../modules/lambda"
  name                   = local.app
  runtime                = "python3.12"
  handler                = "main.handler"
  layers                 = []
  environment            = {}
  s3_bucket              = aws_s3_object.artifact.bucket
  s3_key                 = aws_s3_object.artifact.key
  policy                 = data.aws_iam_policy_document.lambda.json
  subnet_ids             = var.subnet_ids
  security_group_ids     = [aws_security_group.lambda.id]
  file_system_arn        = aws_efs_file_system.this.arn
  file_system_mount_path = "/mnt/efs"
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions   = ["none:null"]
    resources = ["*"]
  }
}
