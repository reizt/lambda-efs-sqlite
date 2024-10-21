variable "app" {
  type = string
}
locals {
  app = var.app
}

variable "vpc_id" {
  type = string
}
variable "subnet_id" {
  type = string
}

output "name" {
  value = module.lambda.name
}
output "invoke_arn" {
  value = module.lambda.invoke_arn
}

resource "aws_s3_bucket" "this" {
  bucket = "reizt-lambda-efs-sqlite"
}

data "archive_file" "artifact" {
  source_dir  = "./src"
  type        = "zip"
  output_path = "./lambda.zip"
}

resource "aws_s3_object" "artifact" {
  bucket = aws_s3_bucket.this.bucket
  key    = "lambda.zip"
  source = data.archive_file.artifact.output_path
  etag   = data.archive_file.artifact.output_base64sha256
}

locals {
  requirements_file = "requirements.lock"
  requirements_hash = filemd5(local.requirements_file)
  layer_file        = "layer.zip"
}

resource "null_resource" "create_layer" {
  triggers = {
    hash = local.requirements_hash
  }
  provisioner "local-exec" {
    command = <<EOT
      python -m venv layer
      layer/bin/pip install -r ${local.requirements_file}
      mkdir -p python/python
      cp -r layer/lib python/python
      zip -r ${local.layer_file} python
    EOT
  }
}

resource "aws_s3_object" "layer" {
  bucket = aws_s3_bucket.this.bucket
  key    = "layer.zip"
  source = local.layer_file
  etag   = local.requirements_hash
  depends_on = [
    null_resource.create_layer,
  ]
}

resource "aws_lambda_layer_version" "this" {
  layer_name               = local.app
  compatible_runtimes      = ["python3.12"]
  compatible_architectures = ["x86_64"]
  s3_bucket                = aws_s3_bucket.this.bucket
  s3_key                   = aws_s3_object.layer.key
  source_code_hash         = aws_s3_object.layer.etag
}

resource "aws_efs_file_system" "this" {
  creation_token = local.app
  encrypted      = true
  tags = {
    Name = local.app
  }
}

resource "aws_efs_file_system_policy" "this" {
  file_system_id = aws_efs_file_system.this.id
  policy         = data.aws_iam_policy_document.efs.json
}

data "aws_iam_policy_document" "efs" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [module.lambda.role_arn]
    }
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]
    resources = [
      aws_efs_file_system.this.arn,
    ]
  }
}

resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0700"
    }
  }
  tags = {
    Name = local.app
  }
}

resource "aws_security_group" "efs" {
  name   = "${local.app}-efs"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.app}-efs"
  }
}

resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.efs.id]
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
  layers  = []
  environment = {
    EFS_MOUNT_PATH = local.efs_mount_path
  }
  s3_bucket              = aws_s3_object.artifact.bucket
  s3_key                 = aws_s3_object.artifact.key
  source_code_hash       = aws_s3_object.artifact.etag
  policy                 = data.aws_iam_policy_document.lambda.json
  subnet_ids             = [var.subnet_id]
  security_group_ids     = [aws_security_group.lambda.id]
  file_system_arn        = aws_efs_access_point.this.arn
  file_system_mount_path = local.efs_mount_path
  depends_on             = [aws_efs_mount_target.this]
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
