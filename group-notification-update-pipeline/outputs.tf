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
