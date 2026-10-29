locals {
  ####################
  # The update script builds its own UI/API paths (e.g. "<base>/ng/account/...")
  # so it needs the bare Harness base URL, without a "/gateway" or "/ng" suffix.
  ####################
  harness_ui_base_url = trimsuffix(trimsuffix(var.harness_platform_url, "/ng"), "/gateway")

  harness_platform_url = (
    endswith(var.harness_platform_url, "/ng")
    ?
    var.harness_platform_url
    :
    endswith(var.harness_platform_url, "/gateway")
    ?
    replace(var.harness_platform_url, "/gateway", "/ng")
    :
    "${var.harness_platform_url}/ng"
  )

  pipeline_base_url = join(
    "/",
    [
      local.harness_platform_url,
      "account",
      var.harness_platform_account,
      "all/orgs",
      data.harness_platform_organization.selected.id,
      "projects",
      data.harness_platform_project.selected.id,
      "pipelines",
      harness_platform_pipeline.update_group_notifications.id
    ]
  )
}

output "pipeline_identifier" {
  description = "The ID of the created pipeline"
  value       = harness_platform_pipeline.update_group_notifications.id
}

output "pipeline_url" {
  description = "URL to the pipeline studio"
  value       = "${local.pipeline_base_url}/pipeline-studio?storeType=INLINE"
}

output "pipeline_executions_url" {
  description = "URL to the pipeline execution screen"
  value       = "${local.pipeline_base_url}/executions"
}

output "workflow_identifier" {
  description = "The ID of the created IDP workflow catalog entity"
  value       = harness_platform_idp_catalog_entity.update_group_notifications.identifier
}

output "workflow_scope" {
  description = "The Harness scope (account, organization or project) the IDP workflow was published at"
  value       = local.workflow_project_id != null ? "project" : local.workflow_organization_id != null ? "organization" : "account"
}
