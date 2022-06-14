output "this_role_arn" {
  value       = aws_iam_role.main.arn
  description = "The ARN of the IAM role"
}
output "this_role_name" {
  value       = aws_iam_role.main.name
  description = "The name of the IAM role"
}
