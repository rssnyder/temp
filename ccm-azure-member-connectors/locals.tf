locals {
  required_tags = {
    created_by : "Terraform"
    harnessSolutionsFactory : "true"
    managedResource : "true"
  }

  ####################
  # When declaring tags on a resource parameter and including YAML, the
  # same tags need to be included in the yaml.  This can be done by refering
  # to this local variable - yamlencode(local.common_tags)
  #
  # Note: your yaml will need to include this if it is an inline yaml or
  # replace the `yamlencode(local.common_tags)` with $TAGS if this is a
  # template_file
  # tags:
  #     ${indent(4, yamlencode(local.common_tags))}
  ####################
  common_tags = merge(
    var.tags,
    local.required_tags
  )

  ####################
  # Harness Tags are read into Terraform as a standard Map entry but needs to be
  # converted into a list of key:value entries when declared as a parameter for
  # the resource.
  ####################
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  ####################
  # Normalize the free-form subscription ID input into a clean, deduplicated list.
  # Supports comma-separated and/or one-per-line entries in the same field.
  ####################
  subscription_ids = distinct([
    for s in split(",", replace(var.subscription_ids, "\n", ",")) : trimspace(s) if trimspace(s) != ""
  ])

  identifier_prefix = replace(replace(var.connector_name_prefix, "-", "_"), " ", "_")
}
