resource "azapi_resource" "ca_back" {
  name      = var.ca_name
  location  = var.location
  parent_id = var.resource_group_id
  type      = "Microsoft.App/containerApps@2022-11-01-preview"
  identity {
    type = "UserAssigned"
    identity_ids = [
      var.managed_identity_id
    ]
  }

  body = jsonencode({
    properties : {
      managedEnvironmentId = "${var.cae_id}"
      configuration = {
        secrets = []
        ingress = {
          external   = true
          targetPort = 50505
          transport  = "Http"

          traffic = [
            {
              latestRevision = true
              weight         = 100
            }
          ]
        }
        dapr = {
          enabled = false
        }
      }
      template = {
        containers = [
          {
            name  = "azseachopenai"
            image = "cmendibl3/azseachopenai"
            resources = {
              cpu    = 0.5
              memory = "1Gi"
            }
            env = [
              {
                name  = "AZURE_STORAGE_ACCOUNT"
                value = "${var.storage_account_name}"
              },
              {
                name  = "AZURE_STORAGE_CONTAINER"
                value = "${var.storage_container_name}"
              },
              {
                name  = "AZURE_SEARCH_SERVICE"
                value = "${var.search_service_name}"
              },
              {
                name  = "AZURE_SEARCH_INDEX"
                value = "${var.search_index_name}"
              },
              {
                name  = "AZURE_OPENAI_CHATGPT_MODEL"
                value = "${var.chat_gpt_model}"
              },
              {
                name  = "AZURE_OPENAI_CHATGPT_DEPLOYMENT"
                value = "${var.chat_gpt_deployment}"
              },
              {
                name  = "AZURE_OPENAI_EMB_MODEL_NAME"
                value = "${var.embeddings_model}"
              },
              {
                name  = "AZURE_OPENAI_EMB_DEPLOYMENT"
                value = "${var.embeddings_deployment}"
              },
              {
                name  = "AZURE_OPENAI_SERVICE"
                value = "${var.openai_service_name}"
              },
              {
                name  = "AZURE_TENANT_ID"
                value = "${var.tenant_id}"
              },
              {
                name  = "AZURE_CLIENT_ID"
                value = "${var.managed_identity_client_id}"
              },
              {
                name  = "APP_LOG_LEVEL"
                value = "DEBUG"
              }
            ],
          },
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 1
        }
      }
    }
  })
  response_export_values = ["properties.configuration.ingress.fqdn"]
}
