variable "vpc_cidr" { 
    default = "10.10.0.0/16" 
}
variable "public_subnet_cidrs"  { 
    default = ["10.10.11.0/24","10.10.12.0/24"] 
}
variable "private_subnet_cidrs" { 
    default = ["10.10.22.0/24","10.10.32.0/24"] 
}
variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "app"
}

variable "ami" {
  description = "ami id"
  type        = string
  default     = "ami-1234567890abcdef0"
}

variable "key_name" {
  description = "Pem key name"
  type        = string
  default     = "app.pem"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for ASG"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 4
}

variable "app_port" {
  description = "Port used by the application"
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "Port used by the database"
  type        = number
  default     = 5432
}

variable "db_engine" {
  description = "Database engine for RDS"
  type        = string
  default     = "postgresql"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage (in GB) for RDS"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "version" { 
    type = string 
    description = "DB version"
    default     = 13
    }

variable "ecr_repo_name" {
  description = "ECR repository name for Docker image"
  type        = string
  default     = ecr/nodejs_app
}

variable "domain_name" { 
    type        = string 
    default     = domain.com
    description = "domain name"
    
}
variable "app_domain" { 
    type    = string
    default = app.domain.com
    description = "fully qualified domain name"
}