variable "environment" {

}

variable "terraform" {

}

####################################################################
# Configuration (CloudFormation parameter group: "Configuration")
####################################################################

variable "dagster_organization" {
  type        = string
  description = "Your organization name as it appears in the dagster.cloud subdomain, e.g. `hooli` corresponding with https://hooli.dagster.cloud/."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.dagster_organization))
    error_message = "dagster_organization must match ^[a-zA-Z0-9-_]*$."
  }
}

variable "dagster_deployment" {
  type        = string
  default     = ""
  description = "Your deployment name, e.g. `prod` corresponding with https://hooli.dagster.cloud/prod/. Leave empty to only serve branch deployments."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.dagster_deployment))
    error_message = "dagster_deployment must match ^[a-zA-Z0-9-_]*$."
  }
}

variable "enable_branch_deployments" {
  type        = bool
  default     = false
  description = "Whether this agent should serve branch deployments. See https://docs.dagster.io/deployment/dagster-plus/deploying-code/branch-deployments."
}

####################################################################
# Secrets (CloudFormation parameter group: "Secrets")
####################################################################

variable "agent_token" {
  type        = string
  sensitive   = true
  description = "A Dagster agent token, obtained on https://{organization}.dagster.cloud/{deployment}/org-settings/tokens/."
}

####################################################################
# Agent runtime
####################################################################

variable "enable_zero_downtime_deploys" {
  type        = bool
  default     = false
  description = "Whether to enable zero-downtime deployment for this agent. The old agent is not spun down until the new agent is ready to serve requests."
}

variable "num_replicas" {
  type        = number
  default     = 1
  description = "The number of agent replicas to keep active at a given time."

  validation {
    condition     = var.num_replicas >= 1 && var.num_replicas <= 5
    error_message = "num_replicas must be between 1 and 5."
  }
}

variable "agent_metrics_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable agent metrics. Allows the agent to send metrics to the Dagster Cloud API."
}

variable "code_server_metrics_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable code server metrics. Allows the agent to send metrics to the Dagster Cloud API."
}

variable "agent_memory" {
  type        = string
  default     = "1024"
  description = "The amount of memory (MiB) to allocate to the agent."
}

variable "agent_cpu" {
  type        = string
  default     = "256"
  description = "The amount of AWS CPU units to allocate to the agent."
}

variable "agent_image" {
  type        = string
  default     = "docker.io/dagster/dagster-cloud-agent:1.13.18"
  description = "Container image for the Dagster Cloud agent. Keep the tag in sync with var.template_version."
}

variable "log_retention_in_days" {
  type        = number
  default     = 7
  description = "Retention, in days, for the agent CloudWatch log group."
}

####################################################################
# Networking
####################################################################

variable "aws_region" {
  type        = string
  default     = null
  description = "AWS region to deploy into. Leave null to use the region from the environment/shared config."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the agent VPC."
}

variable "subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  description = "CIDR blocks for the public agent subnets. One subnet is created per entry, placed in successive availability zones."

  validation {
    condition     = length(var.subnet_cidrs) >= 1
    error_message = "At least one subnet CIDR is required."
  }
}

variable "service_discovery_soa_ttl" {
  type        = number
  default     = 100
  description = "TTL for the SOA record of the private DNS namespace."
}

####################################################################
# Misc
####################################################################

variable "name_prefix" {
  type        = string
  default     = "Dagster-Cloud"
  description = "Prefix used when naming the ECS cluster and other named resources."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to every resource that supports tagging."
}
