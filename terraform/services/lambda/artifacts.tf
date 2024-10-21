data "aws_s3_bucket" "this" {
  bucket = "reizt-lambda-efs-sqlite"
}

data "aws_s3_object" "source" {
  for_each = toset(local.apps)

  bucket = data.aws_s3_bucket.this.bucket
  key    = "${each.value}/source.zip"
}

data "aws_s3_object" "layer" {
  for_each = toset(local.apps)

  bucket = data.aws_s3_bucket.this.bucket
  key    = "${each.value}/layer.zip"
}
