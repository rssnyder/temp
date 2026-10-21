# Creates one GCP Cloud Cost member connector per GCP project ID, all accessed
# via the same Harness-managed GCP service account.
resource "harness_platform_connector_gcp_cloud_cost" "member" {
  for_each = toset(local.gcp_project_ids)

  identifier  = "${local.identifier_prefix}_${replace(each.value, "-", "_")}"
  name        = "${local.identifier_prefix}_${replace(each.value, "-", "_")}"
  description = var.description
  tags        = local.common_tags_tuple

  gcp_project_id        = each.value
  service_account_email = var.service_account_email
  features_enabled      = var.features_enabled
}
