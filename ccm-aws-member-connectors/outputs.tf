output "connectors" {
  description = "Map of AWS account ID to the created member connector's identifier and id"
  value = {
    for account_id, connector in harness_platform_connector_awscc.member : account_id => {
      identifier = connector.identifier
      id         = connector.id
    }
  }
}
