data "harness_platform_organization" "selected" {
  identifier = var.organization_id
}

data "harness_platform_project" "selected" {
  identifier = var.project_id
  org_id     = data.harness_platform_organization.selected.id
}

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
