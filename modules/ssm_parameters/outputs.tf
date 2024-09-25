output "policy_arn" {
  value = module.iam_policy_ssm_param_group.ssm_param_read_only_policy_arn
}