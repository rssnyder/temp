output "stage_template_id" {
  description = "Identifier of the CD K8s rolling deploy stage template"
  value       = harness_platform_template.sta_cd_k8s_rolling_deploy.identifier
}

output "pipeline_template_id" {
  description = "Identifier of the CD K8s deploy pipeline template (Dev -> Test -> Approval -> Prod)"
  value       = harness_platform_template.pipe_cd_k8s_deploy.identifier
}

output "helm_connector_id" {
  description = "Identifier of the standard Helm chart connector"
  value       = harness_platform_connector_oci_helm.standard_helm_chart.identifier
}

output "base_helm_values_file_id" {
  description = "Identifier of the base Helm values file in the Harness File Store"
  value       = harness_platform_file_store_file.base_helm_values.identifier
}
