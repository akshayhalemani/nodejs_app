output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecr_iam_role_name" {
  description = "IAM role name for EC2 to pull from ECR"
  value       = aws_iam_role.ec2_ecr_role.name
}