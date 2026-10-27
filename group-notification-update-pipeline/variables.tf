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

## Harness Hierarchy Setup Details
variable "organization_id" {
  type        = string
  description = "[Required] Provide an existing organization reference ID.  Must exist before execution"
}

variable "project_id" {
  type        = string
  description = "[Required] Provide an existing project reference ID.  Must exist before execution"
}

################################################
# Pipeline Configuration
################################################
variable "pipeline_identifier" {
  type        = string
  description = "[Optional] Identifier of the created pipeline"
  default     = "update_group_notifications"
}

variable "harness_api_key_secret_ref" {
  type        = string
  description = "[Required] Reference to an existing Harness Secret holding an API key (PAT/SAT) with View and Manage permission on user groups at every scope you intend to update. Must be scope-qualified (e.g. account.harness_api_key, org.harness_api_key) or a bare identifier for a project secret"
}

variable "docker_connector_ref" {
  type        = string
  description = "[Optional] Docker registry connector used by the Run step to pull the SDK image (an anonymous Docker Hub connector works; the image is public). Must exist before execution"
  default     = "account.harnessImage"
}

variable "sdk_image" {
  type        = string
  description = "[Optional] Image with harness-platform-sdk preinstalled, used by the Run step. Pin a version tag rather than latest"
  default     = "harnesssolutionfactory/harness-platform-sdk:v1.1.0"
}

################################################
# Advanced Kubernetes Step Group Configuration
#
# The pipeline runs the update script in a Custom stage step group, which
# always executes on a Kubernetes cluster (there is no Cloud build
# infrastructure option for step groups outside of CI stages).
################################################
variable "kubernetes_connector" {
  type        = string
  description = "[Required] Kubernetes connector for the step group's infrastructure (e.g. \"account.my_cluster\"). Must exist before execution"
}

variable "kubernetes_namespace" {
  type        = string
  description = "[Optional] Kubernetes namespace the step group's pod runs in"
  default     = "default"
}

variable "kubernetes_node_selectors" {
  type        = map(any)
  description = "[Optional] Kubernetes node selectors for scheduling the step group's pod"
  default     = {}
}

variable "kubernetes_override_image_connector" {
  type        = string
  description = "[Optional] Container registry connector to override the default connector Harness uses for its internal images. Must exist before execution. To not set this, ensure the value is 'skipped'"
  default     = "skipped"
}

variable "kubernetes_service_account" {
  type        = string
  description = "[Optional] Kubernetes service account name to run the step group's pod as, overriding the namespace default. To not set this, ensure the value is 'skipped'"
  default     = "skipped"
}

################################################
# IDP Workflow Configuration
#
# The IDP Workflow is the catalog form end users fill in to run the pipeline.
# Its scope is independent of the pipeline's own organization_id/project_id
# above, so it can be published somewhere else entirely (e.g. account level,
# or a different org/project) than where the pipeline itself lives.
################################################
variable "workflow_identifier" {
  type        = string
  description = "[Optional] Identifier of the IDP workflow catalog entity"
  default     = "update_group_notifications"
}

variable "workflow_owner" {
  type        = string
  description = "[Optional] IDP catalog owner of the workflow (e.g. a Backstage group entity reference such as group:default/HSF_Users)"
  default     = "group:default/HSF_Users"
}

variable "workflow_organization_id" {
  type        = string
  description = "[Optional] Organization to publish the IDP workflow into. Leave as 'skipped' to publish it at the account level. Independent of organization_id above"
  default     = "skipped"
}

variable "workflow_project_id" {
  type        = string
  description = "[Optional] Project to publish the IDP workflow into. Requires workflow_organization_id to also be set. Leave as 'skipped' to publish the workflow at the organization (or account) level"
  default     = "skipped"

  validation {
    condition     = var.workflow_project_id == "skipped" || var.workflow_organization_id != "skipped"
    error_message = "workflow_organization_id must be set when workflow_project_id is provided."
  }
}

variable "restrict_to_user_group_membership" {
  type        = bool
  description = "[Optional] When true (default), the operational workflow's user group picker only lets a user pick groups they are a member of. Set to false to let a user modify any user group"
  default     = true
}
