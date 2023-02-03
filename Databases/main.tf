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

resource "azurerm_resource_group" "DatabaseResourceGroup" {
  name     = "DatabaseResourceGroup"
  location = "eastus"
}

resource "azurerm_virtual_network" "DataVnet" {
  name                = "DataVnet"
  address_space       = ["10.7.0.0/16"]
  location            = azurerm_resource_group.DatabaseResourceGroup.location
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
}

resource "azurerm_subnet" "SubnetPostgres" {
  name                 = "SubnetPostgres"
  resource_group_name  = azurerm_resource_group.DatabaseResourceGroup.name
  virtual_network_name = azurerm_virtual_network.DataVnet.name
  address_prefixes     = ["10.7.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_postgresql_server" "postgres-server-1" {
  name                = "postgres-server-1"
  location            = azurerm_resource_group.DatabaseResourceGroup.location
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name

  sku_name = "GP_Gen5_2"

  storage_mb            = 5120
  backup_retention_days = 7


  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_virtual_network_rule" "PostgresVentRule" {
  name                                 = "PostgresVentRule"
  resource_group_name                  = azurerm_resource_group.DatabaseResourceGroup.name
  server_name                          = azurerm_postgresql_server.postgres-server-1.name
  subnet_id                            = azurerm_subnet.SubnetPostgres.id
  ignore_missing_vnet_service_endpoint = true
}

resource "azurerm_postgresql_database" "victorplatformdb" {
  name                = "victorplatformdb"
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  server_name         = azurerm_postgresql_server.postgres-server-1.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

