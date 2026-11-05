####################
# Account-level Service Account the pipeline's Run step authenticates as to
# update user groups. Granted only the ability to edit user groups (no other
# permissions), scoped across the whole account hierarchy so it can update
# account, org and project level groups - matching the update script's own
# scope support.
#
# NOTE: "core_usergroup_manage" is the most specific Harness permission
# identifier available for editing user groups - as far as could be verified,
# Harness does not expose a narrower "edit only" permission distinct from
# manage (create/edit/delete) for this resource type. Confirm against the
# permission list in Account Settings > Roles > Create Role before relying on
# this for strict least-privilege.
####################
resource "harness_platform_service_account" "notification_updater" {
  identifier  = "${var.pipeline_identifier}_sa"
  name        = "Update Group Notifications Service Account"
  email       = "${var.pipeline_identifier}_sa@service.harness.io"
  description = "Used by the Update Group Notifications pipeline to edit user group notification settings"
  account_id  = var.harness_platform_account
  tags        = local.common_tags_tuple
}

resource "harness_platform_apikey" "notification_updater" {
  identifier  = "${var.pipeline_identifier}_sa_key"
  name        = "Update Group Notifications Service Account API Key"
  parent_id   = harness_platform_service_account.notification_updater.identifier
  apikey_type = "SERVICE_ACCOUNT"
  account_id  = var.harness_platform_account
  tags        = local.common_tags_tuple
}

resource "harness_platform_token" "notification_updater" {
  identifier  = "${var.pipeline_identifier}_sa_token"
  name        = "Update Group Notifications Service Account Token"
  parent_id   = harness_platform_service_account.notification_updater.identifier
  apikey_id   = harness_platform_apikey.notification_updater.identifier
  apikey_type = "SERVICE_ACCOUNT"
  account_id  = var.harness_platform_account
  tags        = local.common_tags_tuple
}

resource "harness_platform_roles" "usergroup_editor" {
  identifier           = "${var.pipeline_identifier}_usergroup_editor"
  name                 = "Update Group Notifications User Group Editor"
  description          = "Grants only the ability to edit user groups, for the Update Group Notifications service account"
  permissions          = ["core_usergroup_manage"]
  allowed_scope_levels = ["account"]
  tags                 = local.common_tags_tuple
}

resource "harness_platform_resource_group" "usergroup_access" {
  identifier  = "${var.pipeline_identifier}_usergroup_access"
  name        = "Update Group Notifications User Group Access"
  description = "Targets all user groups across the account hierarchy for the Update Group Notifications service account"
  account_id  = var.harness_platform_account
  tags        = local.common_tags_tuple

  allowed_scope_levels = ["account"]

  included_scopes {
    # Reaches org and project level user groups too, matching the update
    # script's own support for updating a group at any scope.
    filter     = "INCLUDING_CHILD_SCOPES"
    account_id = var.harness_platform_account
  }

  resource_filter {
    include_all_resources = false
    resources {
      resource_type = "USERGROUP"
    }
  }
}

resource "harness_platform_role_assignments" "usergroup_access_sa" {
  identifier                = "${var.pipeline_identifier}_usergroup_editor_sa"
  resource_group_identifier = harness_platform_resource_group.usergroup_access.id
  role_identifier           = harness_platform_roles.usergroup_editor.id

  principal {
    identifier  = harness_platform_service_account.notification_updater.identifier
    scope_level = "account"
    type        = "SERVICE_ACCOUNT"
  }

  disabled = false
  managed  = false
}

####################
# The service account's API key, stored as a secret in the pipeline's own
# project so the Run step can reference it with <+secrets.getValue(...)>.
####################
resource "harness_platform_secret_text" "notification_updater_api_key" {
  identifier  = "${var.pipeline_identifier}_sa_api_key"
  name        = "Update Group Notifications Service Account API Key"
  description = "API key for the service account the Update Group Notifications pipeline authenticates as"
  org_id      = data.harness_platform_organization.selected.id
  project_id  = data.harness_platform_project.selected.id
  tags        = local.common_tags_tuple

  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = harness_platform_token.notification_updater.value
}
