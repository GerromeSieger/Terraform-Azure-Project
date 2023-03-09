terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.40.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "victor-1" {
  name     = "victor-1"
  location = "eastus"
}

resource "azurerm_storage_account" "victorifahstorageaccount" {
  name                     = "victorifahstorageaccount"
  resource_group_name      = azurerm_resource_group.victor-1.name
  location                 = azurerm_resource_group.victor-1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "gerrome-plan" {
  name                = "gerrome-plan"
  resource_group_name = azurerm_resource_group.victor-1.name
  location            = azurerm_resource_group.victor-1.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "vic-function-1" {
  name                = "vic-function-1"
  resource_group_name = azurerm_resource_group.victor-1.name
  location            = azurerm_resource_group.victor-1.location

  storage_account_name       = azurerm_storage_account.victorifahstorageaccount.name
  storage_account_access_key = azurerm_storage_account.victorifahstorageaccount.primary_access_key
  service_plan_id            = azurerm_service_plan.gerrome-plan.id

  site_config {}
}