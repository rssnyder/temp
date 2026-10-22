# CCM GCP Member Connectors

## Summary

This module creates GCP Cloud Cost Management (CCM) connectors for a list of GCP "member" projects, all accessed
via the same Harness-managed GCP service account. The service account must already have been granted the
required read access on every project.

This Template will create the following resources:
- One `harness_platform_connector_gcp_cloud_cost` per GCP project ID supplied

_Note: This module is intended for **member** projects only. It does not set `billing_export_spec`, which is only
applicable to a payer/billing-account connector, and therefore does not support the `BILLING` feature._

## Providers
This template is designed to be used as a Terraform Module. To leverage this module, an Harness provider configuration must be added to the calling template as defined by the [Harness Provider - Docs](https://registry.terraform.io/providers/harness/harness/latest/docs).

To aid in the setup and use of this module, we have added a file to the root of this repository called `providers.tf.example`. This file can be used as the basis for configuring your own `providers.tf` file for the calling template

_**Note**: If using this as module as a template, be sure to copy the provider sample file from the root of the repository into this directory prior to execution._
- Save a copy of the file as `providers.tf`
- Either configure the variables as defined or use their corresponding variables.

_**Note**: The gitignore file in this repository explicitly ignores any file called `providers.tf` from commits and changes._

### Terraform required providers declaration
```
terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    // Harness provider for platform resource management
    harness = {
      source  = "harness/harness"
      version = ">= 0.45"
    }
  }
}
```

## Requirements

The following items must be preconfigured in the target Harness Account
- Harness's GCP service account (`service_account_email`) must already have the required read access granted on every project in `gcp_project_ids`

## Variables

| Name | Mandatory | Description | Type | Default |
| --- | --- | --- | --- | --- |
| harness_platform_url | | Enter the Harness Platform URL.  Defaults to Harness SaaS URL | string | https://app.harness.io/gateway |
| harness_platform_account | X | Enter the Harness Platform Account Number | string ||
| tags | | Provide a Map of Tags to associate with the resources | map(any) |{}|
| gcp_project_ids | X | GCP Project IDs to create member connectors for. Accepts a comma-separated list and/or one project ID per line | string ||
| service_account_email | X | Email of the Harness service account granted access on every project in gcp_project_ids | string ||
| features_enabled | | CCM features to enable on each connector. Valid values: OPTIMIZATION, VISIBILITY, GOVERNANCE | list(string) | ["OPTIMIZATION", "VISIBILITY"] |
| connector_name_prefix | | Prefix used to build each connector's identifier/name | string | gcp_ccm_member |
| description | | Description applied to every created connector | string | "" |

## Terraform TFVARS

Included in this repository is a `terraform.tfvars.example` file with a sample file that can be used to construct your own `terraform.tfvars` file.

- Save a copy of the file as `terraform.tfvars`
- Update the variable values listed in the new TFVAR file

## Outputs

| Name | Description | Type |
| --- | --- | --- |
| connectors | Map of GCP project ID to the created member connector's identifier and id | map(object) |

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](../LICENSE) for full details.
