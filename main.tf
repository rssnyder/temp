resource "harness_platform_pipeline" "update_group_notifications" {
  identifier  = var.pipeline_identifier
  name        = "Update Group Notifications"
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  description = "Set a notification channel on one or more Harness user groups"
  tags        = local.common_tags_tuple

  yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_update_group_notifications.yaml.tpl",
    {
      # Pipeline Setup Details
      PIPELINE_IDENTIFIER : var.pipeline_identifier
      ORGANIZATION_ID : data.harness_platform_organization.selected.id
      PROJECT_ID : data.harness_platform_project.selected.id
      TAGS : yamlencode(local.common_tags)

      # Pipeline Inputs
      HARNESS_BASE_URL : local.harness_ui_base_url
      API_KEY_SECRET_REF : var.harness_api_key_secret_ref
      DOCKER_CONNECTOR_REF : var.docker_connector_ref
      SDK_IMAGE : var.sdk_image
      SCRIPT : file("${path.module}/scripts/update_user_groups.py")

      # Advanced Kubernetes Step Group Configuration
      KUBERNETES_CONNECTOR : var.kubernetes_connector
      KUBERNETES_NAMESPACE : var.kubernetes_namespace
      KUBERNETES_NODESELECTORS : local.kubernetes_node_selectors_yaml
      KUBERNETES_IMAGE_CONNECTOR : var.kubernetes_override_image_connector
      KUBERNETES_SERVICE_ACCOUNT : var.kubernetes_service_account
    }
  )
}

####################
# The IDP Workflow is the catalog form end users fill in to run the pipeline.
# Its scope (account/org/project) is independent of the pipeline's own scope
# above - see locals.workflow_organization_id/workflow_project_id.
####################
resource "harness_platform_idp_catalog_entity" "update_group_notifications" {
  identifier = var.workflow_identifier
  kind       = "workflow"
  org_id     = local.workflow_organization_id
  project_id = local.workflow_project_id

  yaml = templatefile(
    "${path.module}/templates/workflows/workflow_update_group_notifications.yaml.tpl",
    {
      WORKFLOW_IDENTIFIER : var.workflow_identifier
      ORG_LINE : local.workflow_organization_id != null ? "orgIdentifier: ${local.workflow_organization_id}\n" : ""
      PROJECT_LINE : local.workflow_project_id != null ? "projectIdentifier: ${local.workflow_project_id}\n" : ""
      OWNER : var.workflow_owner

      PIPELINE_URL : "${local.pipeline_base_url}/pipeline-studio?storeType=INLINE"
      OUTPUT_PREFIX : local.workflow_output_prefix

      # Scopes the user group picker's suggestions toward the pipeline's own org
      PIPELINE_ORG_ID : data.harness_platform_organization.selected.id

      RESTRICT_TO_USER_MEMBERSHIP : var.restrict_to_user_group_membership
      USER_GROUPS_DESCRIPTION : var.restrict_to_user_group_membership ? "Groups you are a member of, at any scope. Add one entry per group." : "Any user group, at any scope. Add one entry per group."
    }
  )
}
