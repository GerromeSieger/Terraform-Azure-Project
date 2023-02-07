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

resource "azurerm_virtual_network" "DBVnet" {
  name                = "DBVnet"
  address_space       = ["10.7.0.0/16"]
  location            = azurerm_resource_group.DatabaseResourceGroup.location
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
}

resource "azurerm_subnet" "SubnetPostgres" {
  name                 = "SubnetPostgres"
  resource_group_name  = azurerm_resource_group.DatabaseResourceGroup.name
  virtual_network_name = azurerm_virtual_network.DBVnet.name
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

# redis

resource "azurerm_redis_cache" "victorifahrediscache" {
  name                = "victorifahrediscache"
  location            = azurerm_resource_group.DatabaseResourceGroup.location
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
    maxmemory_reserved = 2
    maxmemory_delta    = 2
    maxmemory_policy   = "allkeys-lru"
  }
}

#Key vault

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "KeyVault-postgres-Ifah-1" {
  name                = "KeyVault-postgres-Ifah-1"
  location            = azurerm_resource_group.DatabaseResourceGroup.location
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"

  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "server" {
  key_vault_id = azurerm_key_vault.KeyVault-postgres-Ifah-1.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Get", "UnwrapKey", "WrapKey"]
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.KeyVault-postgres-Ifah-1.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id


  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_key" "postgres-key" {
  name         = "postgres-key"
  key_vault_id = azurerm_key_vault.KeyVault-postgres-Ifah-1.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_key_vault_access_policy.server,
  ]
}

resource "azurerm_postgresql_server_key" "pgdbkey" {
  server_id        = azurerm_postgresql_server.postgres-server-1.id
  key_vault_key_id = azurerm_key_vault_key.postgres-key.id
}