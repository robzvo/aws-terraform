environment = "dev"
aws_region = "us-east-2"
terraform = true


# https://<dagster_organization>.dagster.cloud/
dagster_organization = "robzvo"

# https://<dagster_organization>.dagster.cloud/<dagster_deployment>/
# Leave as "" to only serve branch deployments.
dagster_deployment = "prod"

enable_branch_deployments = true

# Obtain from https://<org>.dagster.cloud/<deployment>/org-settings/tokens/
# Prefer supplying this via TF_VAR_agent_token instead of a file on disk.
agent_token = "agent:****:###############################"

# Agent sizing / behaviour
num_replicas                 = 1
agent_cpu                    = "256"
agent_memory                 = "1024"
enable_zero_downtime_deploys = false
agent_metrics_enabled        = false
code_server_metrics_enabled  = false

tags = {
  Project = "dagster-cloud"
}
