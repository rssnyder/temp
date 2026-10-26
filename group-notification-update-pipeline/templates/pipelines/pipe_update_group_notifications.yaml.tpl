pipeline:
  name: Update Group Notifications
  identifier: ${PIPELINE_IDENTIFIER}
  orgIdentifier: ${ORGANIZATION_ID}
  projectIdentifier: ${PROJECT_ID}
  tags:
    ${indent(4, TAGS)}
  variables:
    - name: user_groups
      type: String
      description: Comma-separated user groups to update (account.<id>, org.<id> or a bare identifier)
      required: true
      value: <+input>
    - name: notification_type
      type: String
      description: Notification channel type to set
      required: true
      value: <+input>.allowedValues(EMAIL,SLACK,PAGERDUTY,MSTEAMS)
    - name: notification_value
      type: String
      description: Group email address, Slack/Teams webhook URL, or PagerDuty key, matching the type
      required: true
      value: <+input>
  stages:
    - stage:
        name: Update User Groups
        identifier: update_user_groups
        description: ""
        type: Custom
        spec:
          execution:
            steps:
              - stepGroup:
                  name: Update User Groups
                  identifier: update_user_groups_group
                  stepGroupInfra:
                    type: KubernetesDirect
                    spec:
                      connectorRef: ${KUBERNETES_CONNECTOR}
                      namespace: ${KUBERNETES_NAMESPACE}
                      automountServiceAccountToken: true
                      %{~ if KUBERNETES_SERVICE_ACCOUNT != "skipped" ~}
                      serviceAccountName: ${KUBERNETES_SERVICE_ACCOUNT}
                      %{~ endif ~}
                      %{~ if KUBERNETES_NODESELECTORS != "skipped" ~}
                      nodeSelector:
                        ${indent(24, KUBERNETES_NODESELECTORS)}
                      %{~ endif ~}
                      %{~ if KUBERNETES_IMAGE_CONNECTOR != "skipped" ~}
                      harnessImageConnectorRef: ${KUBERNETES_IMAGE_CONNECTOR}
                      %{~ endif ~}
                  steps:
                    - step:
                        type: Run
                        name: Set Notification Channel
                        identifier: set_notification_channel
                        spec:
                          connectorRef: ${DOCKER_CONNECTOR_REF}
                          image: ${SDK_IMAGE}
                          shell: Python
                          command: |-
                            ${indent(28, SCRIPT)}
                          envVariables:
                            HARNESS_BASE_URL: ${HARNESS_BASE_URL}
                            HARNESS_API_KEY: <+secrets.getValue("${API_KEY_SECRET_REF}")>
                            ACCOUNT_ID: <+account.identifier>
                            ORG_ID: <+pipeline.orgIdentifier>
                            PROJECT_ID: <+pipeline.projectIdentifier>
                            USER_GROUPS: <+pipeline.variables.user_groups>
                            NOTIFICATION_TYPE: <+pipeline.variables.notification_type>
                            NOTIFICATION_VALUE: <+pipeline.variables.notification_value>
                          outputVariables:
                            - name: UPDATED_GROUPS
                              type: String
                              value: UPDATED_GROUPS
                            - name: UNCHANGED_GROUPS
                              type: String
                              value: UNCHANGED_GROUPS
                        timeout: 10m
        tags: {}
