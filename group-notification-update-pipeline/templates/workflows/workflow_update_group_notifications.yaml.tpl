apiVersion: harness.io/v1
kind: Workflow
name: Update Group Notifications
identifier: ${WORKFLOW_IDENTIFIER}
${ORG_LINE}${PROJECT_LINE}type: harness_project
owner: ${OWNER}
description: Set a notification channel on one or more of your Harness user groups.
metadata: {}
spec:
  lifecycle: production
  output:
    links:
      - title: Pipeline Execution
        url: $${{ steps.trigger.output.PipelineUrl }}
    text:
      - title: Updated Groups
        content: |
          $${{ steps.trigger.output['${OUTPUT_PREFIX}.UPDATED_GROUPS'] }}
      - title: Already Up To Date
        content: |
          $${{ steps.trigger.output['${OUTPUT_PREFIX}.UNCHANGED_GROUPS'] }}
  parameters:
    - title: User Groups
      required:
        - user_groups
      properties:
        token:
          title: Harness Token
          type: string
          ui:widget: password
          ui:field: HarnessAuthToken
        user_groups:
          title: User Groups
          description: ${USER_GROUPS_DESCRIPTION}
          type: array
          minItems: 1
          uniqueItems: true
          items:
            type: string
            ui:field: HarnessUserGroupPicker
            ui:options:
              filterByUserMembership: ${RESTRICT_TO_USER_MEMBERSHIP}
              additionalScopes:
                - orgIdentifier: ${PIPELINE_ORG_ID}
                  includeChildScopes: false
    - title: Notification Channel
      required:
        - notification_type
        - notification_value
      properties:
        notification_type:
          title: Notification Type
          description: Only this channel type is changed; other channels on the group are kept.
          type: string
          enum:
            - EMAIL
            - SLACK
            - PAGERDUTY
            - MSTEAMS
          enumNames:
            - Email
            - Slack
            - PagerDuty
            - Microsoft Teams
        notification_value:
          title: Notification Target
          description: Email address for Email, webhook URL for Slack or Microsoft Teams, integration key for PagerDuty.
          type: string
  steps:
    - id: trigger
      name: Update group notifications
      action: trigger:harness-custom-pipeline
      input:
        url: "${PIPELINE_URL}"
        inputset:
          user_groups: $${{ parameters.user_groups | join(',') }}
          notification_type: $${{ parameters.notification_type }}
          notification_value: $${{ parameters.notification_value }}
        apikey: $${{ parameters.token }}
        showOutputVariables: true
