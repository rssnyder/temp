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

variable "organization_id" {
  type        = string
  description = "[Optional] Existing Organization ID for use with template. Must exist before execution."
  default     = null
}

variable "project_id" {
  type        = string
  description = "[Optional] Existing Project ID for use with template. Must exist before execution."
  default     = null
}

#####################################
# Helm Chart Connector Variables
#####################################

variable "helm_chart_override_url" {
  type        = string
  description = "[Optional] URL of a customer-provided 'standard helm chart' to use instead of the Harness default chart. If null, the default chart URL is used."
  default     = null
}

variable "helm_connector_delegate_selectors" {
  type        = list(string)
  description = "[Optional] Delegate selectors to use for the Helm chart connector."
  default     = []
}

variable "helm_connector_username" {
  type        = string
  description = "[Optional] Username for the Helm chart connector. Leave null for anonymous access."
  default     = null
}

variable "helm_connector_password_ref" {
  type        = string
  description = "[Optional] Secret reference for the Helm chart connector password. Required if helm_connector_username is set."
  default     = null
}

variable "base_values_override_content" {
  type        = string
  description = "[Optional] Raw YAML content of a customer-provided base Helm values file, uploaded to the Harness File Store as an override. If null, the bundled default values file is used."
  default     = null
}
