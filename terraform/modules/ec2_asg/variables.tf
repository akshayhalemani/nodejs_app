variable "region" { 
    type = string 
}
variable "vpc_id" { 
    type = string 
}
variable "subnet_ids" { 
    type = list(string) 
}
variable "instance_type" {
    type = string 
}
variable "min_size" { 
    type = number 
}
variable "max_size" { 
    type = number 
}
variable "app_port" { 
    type = number 
}
variable "db_port" { 
    type = number 
}
variable "ecr_repo" { 
    type = string 
}
variable "target_group_arns" { 
    type = list(string) 
}
variable "key_name" { 
    type = string 
}
variable "ami" { 
    type = string 
}
variable "name" { 
    type = string 
}

