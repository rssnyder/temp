# Update Group Notifications

Deploys a Harness pipeline that sets a notification channel (Email, Slack, PagerDuty or
Microsoft Teams) on one or more Harness user groups at any scope (account, org or project).

## Summary

This Template will create the following resources:
- A Harness pipeline, `Update Group Notifications`, with pipeline variables `user_groups`,
  `notification_type` and `notification_value` filled in at run time. The pipeline runs a Python
  script (via `harness-platform-sdk`) in a Custom stage step group that updates the requested
  notification channel on each listed group, leaving its other channels untouched.
- An IDP catalog Workflow (a form end users fill in to run the pipeline above). Its scope
  (`workflow_organization_id`/`workflow_project_id`) is independent of the pipeline's own
  `organization_id`/`project_id` - the workflow can be published at the account level (or a
  different org/project) than wherever the pipeline itself lives.

## Providers

This template is designed to be used as a Terraform Module. To leverage this module, an Harness
provider configuration must be added to the calling template as defined by the
[Harness Provider - Docs](https://registry.terraform.io/providers/harness/harness/latest/docs).

To aid in the setup and use of this module, we have added a file to the root of this repository
called `providers.tf.example`. This file can be used as the basis for configuring your own
`providers.tf` file for the calling template.

- Save a copy of the file as `providers.tf`
- Either configure the variables as defined or use their corresponding variables.

_**Note**: The gitignore file in this repository explicitly ignores any file called `providers.tf`
from commits and changes._

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

- An existing Organization and Project
- A Harness Secret containing an API key (PAT/SAT) with View and Manage permission on user groups
  at every scope you intend to update
- An existing Kubernetes connector (and namespace) the step group's pod can run on. There is no
  Cloud build infrastructure option for step groups outside of CI stages, so this is always
  required

## Variables

_Note: When providing `_ref` values, please ensure that these are prefixed with the correct
location details depending if the connector is at the Organization (org.) or Account (account.)
levels. For Project Connectors, nothing else is required excluding the reference ID for the
connector._

| Name | Mandatory | Description | Type | Default |
| --- | --- | --- | --- | --- |
| harness_platform_url | | Enter the Harness Platform URL.  Defaults to Harness SaaS URL | string | https://app.harness.io/gateway |
| harness_platform_account | X | Enter the Harness Platform Account Number | string ||
| tags | | Provide a Map of Tags to associate with the resources | map(any) |{}|
| organization_id | X | Provide an existing organization reference ID.  Must exist before execution | string ||
| project_id | X | Provide an existing project reference ID.  Must exist before execution | string ||
| pipeline_identifier | | Identifier of the created pipeline | string | update_group_notifications |
| harness_api_key_secret_ref | X | Reference to an existing Harness Secret holding an API key with View and Manage permission on user groups | string ||
| docker_connector_ref | | Docker registry connector used by the Run step to pull the SDK image | string | account.harnessImage |
| sdk_image | | Image with harness-platform-sdk preinstalled, used by the Run step | string | harnesssolutionfactory/harness-platform-sdk:v1.1.0 |

### Advanced Kubernetes Step Group Configuration

The pipeline's update step runs inside a Custom stage step group, which always runs on a
Kubernetes cluster. These variables control that infrastructure, matching the "advanced" K8s
options (service account and image overrides) used by other pipelines in this repository.

| Name | Mandatory | Description | Type | Default |
| --- | --- | --- | --- | --- |
| kubernetes_connector | X | Kubernetes connector for the step group's infrastructure (e.g. "account.my_cluster"). Must exist before execution | string ||
| kubernetes_namespace | | Kubernetes namespace the step group's pod runs in | string | default |
| kubernetes_node_selectors | | Kubernetes node selectors for scheduling the step group's pod | map(any) | {} |
| kubernetes_override_image_connector | | Container registry connector to override the default connector Harness uses for its internal images. To not set this, ensure the value is 'skipped' | string | skipped |
| kubernetes_service_account | | Kubernetes service account name to run the step group's pod as, overriding the namespace default. To not set this, ensure the value is 'skipped' | string | skipped |

### IDP Workflow Configuration

The IDP catalog Workflow is the form end users fill in to run the pipeline (not the pipeline
itself). Its scope is fully independent of `organization_id`/`project_id` above - e.g. it can be
published at the account level for anyone to use, while the pipeline lives in one specific
project.

| Name | Mandatory | Description | Type | Default |
| --- | --- | --- | --- | --- |
| workflow_identifier | | Identifier of the IDP workflow catalog entity | string | update_group_notifications |
| workflow_owner | | IDP catalog owner of the workflow (a Backstage group entity reference) | string | group:default/HSF_Users |
| workflow_organization_id | | Organization to publish the IDP workflow into. To publish at the account level, ensure the value is 'skipped' | string | skipped |
| workflow_project_id | | Project to publish the IDP workflow into. Requires workflow_organization_id to also be set. To publish at the organization (or account) level, ensure the value is 'skipped' | string | skipped |
| restrict_to_user_group_membership | | When true, the operational workflow's user group picker only lets a user pick groups they are a member of. Set to false to let a user modify any user group | bool | true |

## Terraform TFVARS

Included in this repository is a `terraform.tfvars.example` file with a sample file that can be
used to construct your own `terraform.tfvars` file.

- Save a copy of the file as `terraform.tfvars`
- Update the variable values listed in the new TFVAR file

## Outputs

| Name | Description | Type |
| --- | --- | --- |
| pipeline_identifier | The ID of the created pipeline | string |
| pipeline_url | URL to the pipeline studio | string |
| pipeline_executions_url | URL to the pipeline execution screen | string |
| workflow_identifier | The ID of the created IDP workflow catalog entity | string |
| workflow_scope | The Harness scope (account, organization or project) the IDP workflow was published at | string |

## Contributing

A complete [Contributors Guide](../CONTRIBUTING.md) can be found in this repository

## Authors

Module is maintained by Harness, Inc

## License

MIT License. See [LICENSE](../LICENSE) for full details.
