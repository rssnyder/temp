locals {
  required_tags = {
    created_by : "Terraform"
    harnessSolutionsFactory : "true"
    managedResource : "true"
  }

  common_tags = merge(
    var.tags,
    local.required_tags
  )

  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  tier_handler = (
    var.project_id != null
    ?
    ""
    :
    var.organization_id != null
    ?
    "org."
    :
    "account."
  )

  # Common template variables
  common_template_vars = {
    ORGANIZATION_ID = var.organization_id != null ? data.harness_platform_organization.this[0].id : null
    PROJECT_ID      = var.project_id != null ? data.harness_platform_project.this[0].id : null
  }

  # Standard chart maintained by this template, used unless the caller overrides it
  default_helm_chart_url = "oci://ghcr.io/stakater/charts"

  helm_chart_url      = coalesce(var.helm_chart_override_url, local.default_helm_chart_url)
  base_values_content = coalesce(var.base_values_override_content, file("${path.module}/templates/manifests/values_base.yaml"))
}
