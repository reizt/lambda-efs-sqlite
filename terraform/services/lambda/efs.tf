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
      type = "AWS"
      identifiers = [
        for lambda in module.lambda : lambda.role_arn
      ]
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
