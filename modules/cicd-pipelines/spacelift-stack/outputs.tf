output "stack_id" {
  value = spacelift_stack.this.id
}

output "stack_iam_role_id" {
  value = length(aws_iam_role.this) == 1 ? aws_iam_role.this[1].id : null
}

output "stack_iam_role_arn" {
  value = length(aws_iam_role.this) == 1 ? aws_iam_role.this[1].arn : null
}

output "stack_iam_role_policy_arns" {
  value = aws_iam_role_policy_attachment.this[*].policy_arn
}
