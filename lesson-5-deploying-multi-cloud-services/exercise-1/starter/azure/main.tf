# Data block to reference existing resource group
data "azurerm_resource_group" "example" {
  name = "Regroup_4hEF_2G"  # Ensure this is exactly your resource group name in Azure
}

# Storage Account
resource "azurerm_storage_account" "example" {
  name                     = "tscottoudacitystorage"  # Must be globally unique
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# App Service Plan
resource "azurerm_app_service_plan" "example" {  # Correct resource name
  name                = "example-app-service-plan"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  kind                = "FunctionApp"  # Specify kind
  sku {
    tier = "Dynamic"  # Specify an appropriate SKU tier and size
    size = "Y1"
  }
}

# Windows Function App
resource "azurerm_windows_function_app" "example" {
  name                       = "tscotto-udacity-windows-function-app"  # Must be unique
  resource_group_name        = data.azurerm_resource_group.example.name
  location                   = data.azurerm_resource_group.example.location
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    app_settings = {
      "FUNCTIONS_WORKER_RUNTIME" = "dotnet"  # Adjust runtime based on your needs
    }
  }
}