output "names" {
  value = { for key, lambda in module.lambda : key => lambda.name }
}
output "invoke_arns" {
  value = { for key, lambda in module.lambda : key => lambda.invoke_arn }
}
