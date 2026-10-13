# CD Stage Template - standard Kubernetes rolling deploy
resource "harness_platform_template" "sta_cd_k8s_rolling_deploy" {
  lifecycle {
    create_before_destroy = true
  }
  identifier = "CD_K8s_Rolling_Deploy_Template"
  name       = "Kubernetes Rolling Deploy"
  org_id     = local.common_template_vars["ORGANIZATION_ID"]
  project_id = local.common_template_vars["PROJECT_ID"]
  version    = "v1"
  is_stable  = true

  template_yaml = templatefile(
    "${path.module}/templates/stages/sta_cd_k8s_rolling_deploy.yaml",
    merge(local.common_template_vars, {
      TEMPLATE_IDENTIFIER = "CD_K8s_Rolling_Deploy_Template"
      TEMPLATE_NAME       = "Kubernetes Rolling Deploy"
      TEMPLATE_DESC       = "CD Golden Standard Stage template to perform a standard Kubernetes rolling deployment"
      TEMPLATE_VERSION    = "v1"
    })
  )

  tags = local.common_tags_tuple
}
