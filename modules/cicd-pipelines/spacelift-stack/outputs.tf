output "stack_id" {
  value = spacelift_stack.this.id
}

output "stack_iam_role_id" {
  value = aws_iam_role.this.id
}

output "stack_iam_role_arn" {
  value = aws_iam_role.this.arn
}

output "stack_iam_role_policy_arns" {
  value = aws_iam_role_policy_attachment.this[*].policy_arn
}
