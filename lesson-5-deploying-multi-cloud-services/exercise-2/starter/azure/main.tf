data "azurerm_resource_group" "example" {
  name = "Regroup_4hEF_2G"
}

##### Your code starts here #####

# ---------------------
# Azure - AKS Cluster
# ---------------------
resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 3                 # Requirement: 3 nodes
    vm_size    = "Standard_D2s_v3" # Requirement: 2 vCPU, 8GB RAM
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true
}

# ---------------------
# Azure - Storage Account
# ---------------------
resource "azurerm_storage_account" "example" {
  name                     = "tscottoudacitystorage"
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# ---------------------
# Azure - App Service Plan
# ---------------------
resource "azurerm_service_plan" "example" {
  name                = "example-app-service-plan"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  os_type             = "Windows"
  sku_name            = "Y1" # Consumption plan
}

# ---------------------
# Azure - Windows Function App (PowerShell)
# ---------------------
resource "azurerm_windows_function_app" "example" {
  name                = "tscotto-udacity-windows-function-app"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  site_config {
    application_stack {
      powershell_core_version = "7.2" # Ensures PowerShell runtime
    }
  }
}

# ---------------------
# AWS - Glacier Vault
# ---------------------
resource "aws_glacier_vault" "example" {
  name = "my-glacier-vault-example"
}

# ---------------------
# AWS - DynamoDB Table
# ---------------------
resource "aws_dynamodb_table" "example" {
  name         = "my-example-table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}