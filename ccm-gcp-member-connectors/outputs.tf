output "connectors" {
  description = "Map of GCP project ID to the created member connector's identifier and id"
  value = {
    for gcp_project_id, connector in harness_platform_connector_gcp_cloud_cost.member : gcp_project_id => {
      identifier = connector.identifier
      id         = connector.id
    }
  }
}
