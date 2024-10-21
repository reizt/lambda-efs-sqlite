removed {
  from = module.lambda.aws_s3_bucket.this
  lifecycle {
    destroy = false
  }
}
removed {
  from = module.lambda.aws_s3_object.artifact
  lifecycle {
    destroy = false
  }
}
