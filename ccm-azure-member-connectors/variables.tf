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

variable "subscription_ids" {
  type        = string
  description = "[Required] Azure Subscription IDs to create CCM member connectors for. Accepts a comma-separated list and/or one subscription ID per line."

  validation {
    condition = alltrue([
      for id in [for s in split(",", replace(var.subscription_ids, "\n", ",")) : trimspace(s) if trimspace(s) != ""] :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Each Azure subscription ID must be a valid UUID. Separate entries with commas and/or newlines."
  }
}

variable "tenant_id" {
  type        = string
  description = "[Required] Azure Active Directory Tenant ID shared by all subscriptions in subscription_ids"
}

variable "features_enabled" {
  type        = list(string)
  description = "[Optional] CCM features to enable on each member connector. Valid values: OPTIMIZATION, VISIBILITY, GOVERNANCE"
  default     = ["OPTIMIZATION", "VISIBILITY"]

  validation {
    condition     = alltrue([for f in var.features_enabled : contains(["OPTIMIZATION", "VISIBILITY", "GOVERNANCE"], f)])
    error_message = "features_enabled may only contain OPTIMIZATION, VISIBILITY, and/or GOVERNANCE. BILLING is reserved for the payer subscription connector and isn't supported by this module."
  }
}

variable "connector_name_prefix" {
  type        = string
  description = "[Optional] Prefix used to build each connector's identifier/name - connectors are named '<prefix>_<subscription_id>'"
  default     = "azure_ccm_member"
}

variable "description" {
  type        = string
  description = "[Optional] Description applied to every created connector"
  default     = ""
}
