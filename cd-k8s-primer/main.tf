# CD K8s Primer
# Creates the reusable building blocks for enterprise Kubernetes CD:
# - harness_stages.tf: standard rolling deploy Stage template
# - harness_pipelines.tf: Dev -> Test -> Approval -> Prod Pipeline template built on that stage
# - harness_helm.tf: standard Helm chart connector + base values file (overridable per variables.tf)
