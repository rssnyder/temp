# Creates one Azure Cloud Cost member connector per subscription ID, all sharing
# the same Azure Active Directory tenant.
resource "harness_platform_connector_azure_cloud_cost" "member" {
  for_each = toset(local.subscription_ids)

  identifier  = "${local.identifier_prefix}_${replace(each.value, "-", "_")}"
  name        = "${local.identifier_prefix}_${replace(each.value, "-", "_")}"
  description = var.description
  tags        = local.common_tags_tuple

  tenant_id        = var.tenant_id
  subscription_id  = each.value
  features_enabled = var.features_enabled
}
