variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "app_port" { type = number }
variable "domain_name" { type = string }
variable "app_domain" { type = string }
