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

  ####################
  # IDP Workflow scope, resolved independently of the pipeline's organization_id/project_id.
  # null means account level.
  ####################
  workflow_organization_id = var.workflow_organization_id != "skipped" ? data.harness_platform_organization.workflow[0].id : null
  workflow_project_id      = var.workflow_project_id != "skipped" ? data.harness_platform_project.workflow[0].id : null

  # Where the Run step's output variables live in the pipeline execution. Must
  # match the stage, step group and step identifiers in the pipeline YAML template.
  workflow_output_prefix = "pipeline.stages.update_user_groups.spec.execution.steps.update_user_groups_group.steps.set_notification_channel.output.outputVariables"
}
