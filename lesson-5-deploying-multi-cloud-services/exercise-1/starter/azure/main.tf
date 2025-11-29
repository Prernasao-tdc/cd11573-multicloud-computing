# Resource Group Data
data "azurerm_resource_group" "example" {
  name = "Regroup_4hEF_2G"  # Replace with your specific resource group name
}

# Storage Account Configuration
resource "azurerm_storage_account" "example" {
  name                     = "tscottoudacitystorage"  # Ensure this is unique, lowercase, no spaces or punctuation
  resource_group_name       = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

# Service Plan Configuration
resource "azurerm_service_plan" "example" {
  name                  = "example-app-service-plan"
  resource_group_name   = data.azurerm_resource_group.example.name
  location              = data.azurerm_resource_group.example.location
  os_type               = "Windows"  # Specify OS type
  
  sku {
    name = "S1"       # Specify SKU Name
    tier = "Standard" # Specify SKU Tier
  }
}

# Windows Function App Configuration
resource "azurerm_windows_function_app" "example" {
  name                       = "tscottoudacitywindowsfuncapp"  # Ensure this is unique
  resource_group_name        = data.azurerm_resource_group.example.name
  location                   = data.azurerm_resource_group.example.location
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id  # Correct plan reference
  
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = true
    dotnet_framework_version = "v4.0"
    ftps_state = "Disabled"
    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
  }
}
