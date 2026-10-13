# CD Pipeline Template - Dev -> Test -> Approval -> Prod, built on the rolling deploy stage template
resource "harness_platform_template" "pipe_cd_k8s_deploy" {
  lifecycle {
    create_before_destroy = true
  }
  identifier = "CD_K8s_Deploy_Pipeline_Template"
  name       = "Kubernetes Deploy Pipeline"
  org_id     = local.common_template_vars["ORGANIZATION_ID"]
  project_id = local.common_template_vars["PROJECT_ID"]
  version    = "v1"
  is_stable  = true

  template_yaml = templatefile(
    "${path.module}/templates/pipelines/pipe_cd_k8s_deploy.yaml",
    merge(local.common_template_vars, {
      TEMPLATE_IDENTIFIER    = "CD_K8s_Deploy_Pipeline_Template"
      TEMPLATE_NAME          = "Kubernetes Deploy Pipeline"
      TEMPLATE_DESC          = "CD Golden Standard Pipeline template: deploy to Dev, deploy to Test, approval, deploy to Prod"
      TEMPLATE_VERSION       = "v1"
      STAGE_TEMPLATE_ID      = "${local.tier_handler}${harness_platform_template.sta_cd_k8s_rolling_deploy.identifier}"
      STAGE_TEMPLATE_VERSION = harness_platform_template.sta_cd_k8s_rolling_deploy.version
    })
  )

  tags = local.common_tags_tuple

  depends_on = [
    harness_platform_template.sta_cd_k8s_rolling_deploy
  ]
}
