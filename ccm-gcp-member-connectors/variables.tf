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

variable "gcp_project_ids" {
  type        = string
  description = "[Required] GCP Project IDs to create CCM member connectors for. Accepts a comma-separated list and/or one project ID per line."

  validation {
    condition = alltrue([
      for id in [for s in split(",", replace(var.gcp_project_ids, "\n", ",")) : trimspace(s) if trimspace(s) != ""] :
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", id))
    ])
    error_message = "Each GCP project ID must be 6-30 characters, lowercase letters, digits, and hyphens, starting with a letter. Separate entries with commas and/or newlines."
  }
}

variable "service_account_email" {
  type        = string
  description = "[Required] Email of the Harness service account granted access on every project in gcp_project_ids"
}

variable "features_enabled" {
  type        = list(string)
  description = "[Optional] CCM features to enable on each member connector. Valid values: OPTIMIZATION, VISIBILITY, GOVERNANCE"
  default     = ["OPTIMIZATION", "VISIBILITY"]

  validation {
    condition     = alltrue([for f in var.features_enabled : contains(["OPTIMIZATION", "VISIBILITY", "GOVERNANCE"], f)])
    error_message = "features_enabled may only contain OPTIMIZATION, VISIBILITY, and/or GOVERNANCE. BILLING is reserved for the payer project connector and isn't supported by this module."
  }
}

variable "connector_name_prefix" {
  type        = string
  description = "[Optional] Prefix used to build each connector's identifier/name - connectors are named '<prefix>_<gcp_project_id>'"
  default     = "gcp_ccm_member"
}

variable "description" {
  type        = string
  description = "[Optional] Description applied to every created connector"
  default     = ""
}
