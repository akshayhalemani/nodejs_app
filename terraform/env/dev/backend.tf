terraform {
  backend "s3" {
    bucket = "terraform-state-file"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
    encryption = true
    version = enabled
    dynamodb_table = "terraform-lock-table"
  }
}