# CD K8s Primer

This module creates the reusable building blocks required to enable enterprise Kubernetes deployments in Harness CD.

## Summary

This Template will create the following resources:
- A **Stage template** (`CD_K8s_Rolling_Deploy_Template`) implementing a standard Kubernetes rolling deployment (`K8sRollingDeploy` with `K8sRollingRollback`).
- A **Pipeline template** (`CD_K8s_Deploy_Pipeline_Template`) with 4 stages — Deploy to Dev, Deploy to Test, Harness Approval, Deploy to Prod — each deploy stage built on the Stage template above.
- A **Helm chart connector** (`harness_platform_connector_oci_helm`) and a **File Store file** holding the base Helm values, following the pattern in `modules/org/helm_repo.tf`. These default to a standard enterprise chart/values pair but can be overridden by the caller (see Variables below, and `3a` in the IDP workflow). Their identifiers are exposed as outputs for consumption by the downstream template that creates the CD Services (not wired into the Stage/Pipeline templates here).

## Providers

This template is designed to be used as a Terraform Module. To leverage this module, a Harness provider configuration must be added to the calling template as defined by the [Harness Provider - Docs](https://registry.terraform.io/providers/harness/harness/latest/docs).

A sample `providers.tf.example` file is available at the root of this repository. Copy it into this directory as `providers.tf` and configure before running.

### Terraform required providers declaration

```
terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    harness = {
      source  = "harness/harness"
      version = ">= 0.45"
    }
  }
}
```

## Requirements

The following items must be preconfigured in the target Harness Account:
- An Organization and/or Project if deploying below the Account scope
- A delegate capable of reaching the Helm chart source, if credentials/custom URL are used

## Variables

| Name | Mandatory | Description | Type | Default |
| --- | --- | --- | --- | --- |
| harness_platform_url | | Enter the Harness Platform URL. Defaults to Harness SaaS URL | string | https://app.harness.io/gateway |
| harness_platform_account | X | Enter the Harness Platform Account Number | string | |
| tags | | Provide a Map of Tags to associate with the resources | map(any) | {} |
| organization_id | | Existing Organization ID. Must exist before execution | string | null |
| project_id | | Existing Project ID. Must exist before execution | string | null |
| helm_chart_override_url | | URL of a customer "standard helm chart" to use instead of the Harness default chart | string | null |
| helm_connector_delegate_selectors | | Delegate selectors for the Helm chart connector | list(string) | [] |
| helm_connector_username | | Username for the Helm chart connector (anonymous if null) | string | null |
| helm_connector_password_ref | | Secret reference for the Helm chart connector password | string | null |
| base_values_override_content | | Raw YAML content of a customer-provided base Helm values file, uploaded as an override | string | null |

## Terraform TFVARS

A `terraform.tfvars.example` file is included in this repository. Copy it to `terraform.tfvars` and update the values.

## Outputs

| Name | Description | Type |
| --- | --- | --- |
| stage_template_id | Identifier of the CD K8s rolling deploy stage template | string |
| pipeline_template_id | Identifier of the Dev -> Test -> Approval -> Prod pipeline template | string |
| helm_connector_id | Identifier of the standard Helm chart connector | string |
| base_helm_values_file_id | Identifier of the base Helm values file in the File Store | string |

## IDP Workflow

The `.harness/catalog_template.yaml` workflow exposes the "standard helm chart" override described in requirement `3a`: the user may optionally provide their own chart URL and base values file; if left blank, the module's default enterprise chart/values are used.

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository.

## Authors

Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](../LICENSE) for full details.
