output "github_actions_apply_role_arn" {
  value = aws_iam_role.github_actions_apply.arn
}

output "github_actions_plan_role_arn" {
  value = aws_iam_role.github_actions_plan.arn
}

output "github_actions_startstop_role_arn" {
  value = aws_iam_role.github_actions_startstop.arn
}