# Harness Account Setup
variable "harness_platform_url" {
  type        = string
  description = "[Optional] Enter the Harness Platform URL.  Defaults to Harness SaaS URL"
  default     = "https://app.harness.io/gateway"
}

variable "harness_platform_account" {
  type        = string
  description = "[Required] Enter the Harness Platform Account Number"
}

variable "tags" {
  type        = map(any)
  description = "[Optional] Provide a Map of Tags to associate with the resources"
  default     = {}
}

variable "aws_account_ids" {
  type        = string
  description = "[Required] AWS Account IDs to create AWS Cloud Cost member connectors for. Accepts a comma-separated list and/or one account ID per line."

  validation {
    condition = alltrue([
      for id in [for s in split(",", replace(var.aws_account_ids, "\n", ",")) : trimspace(s) if trimspace(s) != ""] :
      can(regex("^[0-9]{12}$", id))
    ])
    error_message = "Each AWS account ID must be a 12-digit number. Separate entries with commas and/or newlines."
  }
}

variable "cross_account_role_name" {
  type        = string
  description = "[Required] Name of the standard cross-account IAM role deployed in every member account (e.g. HarnessCCMRole). Must be identical across all accounts in aws_account_ids."
}

variable "external_id" {
  type        = string
  description = "[Required] External ID configured on the cross-account IAM role's trust policy. Same value is used across all accounts in aws_account_ids."
}

variable "features_enabled" {
  type        = list(string)
  description = "[Optional] CCM features to enable on each member connector. Valid values: OPTIMIZATION, VISIBILITY, GOVERNANCE"
  default     = ["OPTIMIZATION", "VISIBILITY"]

  validation {
    condition     = alltrue([for f in var.features_enabled : contains(["OPTIMIZATION", "VISIBILITY", "GOVERNANCE"], f)])
    error_message = "features_enabled may only contain OPTIMIZATION, VISIBILITY, and/or GOVERNANCE. BILLING is reserved for the payer account connector and isn't supported by this module."
  }
}

variable "connector_name_prefix" {
  type        = string
  description = "[Optional] Prefix used to build each connector's identifier/name - connectors are named '<prefix>_<account_id>'"
  default     = "aws_ccm_member"
}

variable "description" {
  type        = string
  description = "[Optional] Description applied to every created connector"
  default     = ""
}
