####################
# Grants everyone in the account access to run the "Update Group Notifications"
# pipeline, via a Resource Group scoped to the pipeline's own project (targeting
# only this pipeline and the secret holding its service account API key) bound
# to the built-in "_idp_workflow_executor" role for the "_account_all_users"
# account-level group.
####################
resource "harness_platform_resource_group" "pipeline_access" {
  identifier  = "${var.pipeline_identifier}_access"
  name        = "Update Group Notifications Pipeline Access"
  description = "Targets the Update Group Notifications pipeline and its service account secret for IDP workflow execution access"
  account_id  = var.harness_platform_account
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  tags        = local.common_tags_tuple

  allowed_scope_levels = ["project"]

  included_scopes {
    filter     = "EXCLUDING_CHILD_SCOPES"
    account_id = var.harness_platform_account
    org_id     = data.harness_platform_organization.selected.id
    project_id = data.harness_platform_project.selected.id
  }

  resource_filter {
    include_all_resources = false
    resources {
      resource_type = "PIPELINE"
      identifiers   = [harness_platform_pipeline.update_group_notifications.id]
    }
    resources {
      resource_type = "SECRET"
      identifiers   = [harness_platform_secret_text.notification_updater_api_key.id]
    }
  }
}

resource "harness_platform_role_assignments" "pipeline_access_all_users" {
  identifier                = "${var.pipeline_identifier}_idp_workflow_executor_all_users"
  org_id                    = data.harness_platform_organization.selected.id
  project_id                = data.harness_platform_project.selected.id
  resource_group_identifier = harness_platform_resource_group.pipeline_access.id
  role_identifier           = "_pipeline_executor"

  principal {
    identifier  = "_account_all_users"
    scope_level = "account"
    type        = "USER_GROUP"
  }

  disabled = false
  managed  = false
}
