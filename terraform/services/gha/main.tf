variable "app" {
  type = string
}
locals {
  app = var.app
}

module "role" {
  source             = "../../modules/iam-role"
  role_name          = "${local.app}-gha"
  policy_name        = "${local.app}-gha"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  policy             = data.aws_iam_policy_document.this.json
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  repository = "reizt/lambda-efs-sqlite"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.repository}:*"]
    }
  }
}

data "aws_s3_bucket" "this" {
  bucket = "reizt-lambda-efs-sqlite"
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${data.aws_s3_bucket.this.arn}/*",
    ]
  }
}
