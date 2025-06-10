variable "name" { type = string }
variable "engine" { type = string }
variable "instance_class" { type = string }
variable "allocated_storage" { type = number }
variable "username" { type = string }
variable "password" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_port" { type = string }
variable "version" { type = string }

