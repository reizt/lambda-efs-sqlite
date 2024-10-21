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
