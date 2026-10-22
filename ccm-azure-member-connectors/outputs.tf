output "connectors" {
  description = "Map of Azure subscription ID to the created member connector's identifier and id"
  value = {
    for subscription_id, connector in harness_platform_connector_azure_cloud_cost.member : subscription_id => {
      identifier = connector.identifier
      id         = connector.id
    }
  }
}
