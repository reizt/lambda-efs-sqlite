data "aws_s3_bucket" "this" {
  bucket = "reizt-lambda-efs-sqlite"
}

data "aws_s3_object" "source" {
  bucket = data.aws_s3_bucket.this.bucket
  key    = "lambda.zip"
}

data "aws_s3_object" "layer" {
  bucket = data.aws_s3_bucket.this.bucket
  key    = "layer.zip"
}
