# Creates one AWS Cloud Cost member connector per AWS account ID, each assuming
# the same standard cross-account IAM role name deployed in that account.
resource "harness_platform_connector_awscc" "member" {
  for_each = toset(local.aws_account_ids)

  identifier  = "${local.identifier_prefix}_${each.value}"
  name        = "${local.identifier_prefix}_${each.value}"
  description = var.description
  tags        = local.common_tags_tuple

  account_id       = each.value
  features_enabled = var.features_enabled

  cross_account_access {
    role_arn    = "arn:aws:iam::${each.value}:role/${var.cross_account_role_name}"
    external_id = var.external_id
  }
}
