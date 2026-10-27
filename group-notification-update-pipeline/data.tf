data "harness_platform_organization" "selected" {
  identifier = var.organization_id
}

data "harness_platform_project" "selected" {
  identifier = var.project_id
  org_id     = data.harness_platform_organization.selected.id
}

####################
# The IDP workflow (the form end users fill in to trigger the pipeline) can be
# published at a different scope than the pipeline itself - e.g. account level,
# while the pipeline lives in a specific project. These are optional and
# independent of var.organization_id/var.project_id above.
####################
data "harness_platform_organization" "workflow" {
  count      = var.workflow_organization_id == "skipped" ? 0 : 1
  identifier = var.workflow_organization_id
}

data "harness_platform_project" "workflow" {
  count      = var.workflow_project_id == "skipped" ? 0 : 1
  identifier = var.workflow_project_id
  org_id     = data.harness_platform_organization.workflow[0].id
}
