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

  ####################
  # Harness Tags are read into Terraform as a standard Map entry but needs to be
  # converted into a list of key:value entries when declared as a parameter for
  # the resource.
  ####################
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  ####################
  # Advanced Kubernetes step group configuration, rendered for use in the
  # pipeline YAML template. "skipped" means the optional field is omitted.
  ####################
  kubernetes_node_selectors_yaml = length(var.kubernetes_node_selectors) > 0 ? yamlencode(var.kubernetes_node_selectors) : "skipped"
}
