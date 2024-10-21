moved {
  from = module.lambda.aws_lambda_layer_version.this
  to   = module.lambda.aws_lambda_layer_version.this["python"]
}
moved {
  from = module.lambda.module.lambda
  to   = module.lambda.module.lambda["python"]
}
moved {
  from = module.apigw.module.apigw_lambda_proxy
  to   = module.apigw.module.apigw_lambda_proxy["python"]
}
