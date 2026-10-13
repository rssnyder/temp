# Helm chart connector + base values file for enterprise Kubernetes deployments.
# Pattern mirrors modules/org/helm_repo.tf: a connector pointed at a standard
# chart, plus a File Store manifest consumed as the base values override.
resource "harness_platform_connector_oci_helm" "standard_helm_chart" {
  identifier  = "cd_k8s_standard_helm_chart"
  name        = "CD K8s Standard Helm Chart"
  description = "Helm chart connector for the enterprise standard Kubernetes chart. Override via helm_chart_override_url to point at a customer-provided chart."
  org_id      = local.common_template_vars["ORGANIZATION_ID"]
  project_id  = local.common_template_vars["PROJECT_ID"]
  tags        = local.common_tags_tuple

  url                = local.helm_chart_url
  delegate_selectors = var.helm_connector_delegate_selectors

  dynamic "credentials" {
    for_each = var.helm_connector_username != null ? [1] : []
    content {
      username     = var.helm_connector_username
      password_ref = var.helm_connector_password_ref
    }
  }
}

resource "harness_platform_file_store_file" "base_helm_values" {
  identifier  = "cd_k8s_base_helm_values"
  name        = "cd_k8s_base_helm_values"
  description = "Base Helm values override used by the CD K8s Primer rolling deploy stage. Override via base_values_override_content to supply a customer-provided values file."
  org_id      = local.common_template_vars["ORGANIZATION_ID"]
  project_id  = local.common_template_vars["PROJECT_ID"]
  tags        = local.common_tags_tuple

  parent_identifier = "Root"
  content           = local.base_values_content
  mime_type         = "application/yaml"
  file_usage        = "MANIFEST_FILE"
}
