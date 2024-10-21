variable "name" {
  type = string
}
variable "runtime" {
  type = string
}
variable "handler" {
  type = string
}
variable "environment" {
  type = map(string)
}
variable "policy" {
  type = string
}
variable "s3_bucket" {
  type = string
}
variable "s3_key" {
  type = string
}
variable "source_code_hash" {
  type = string
}
variable "layers" {
  type = list(string)
}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_ids" {
  type = list(string)
}
variable "file_system_arn" {
  type = string
}
variable "file_system_mount_path" {
  type = string
}
