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
  location = "West Europe"
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "ifahdevaccount" {
  name                = "ifahdevaccount-${random_integer.ri.result}"
  location            = azurerm_resource_group.DatabaseResourceGroup.location
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = "eastus"
    failover_priority = 1
  }

  geo_location {
    location          = "westus"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "UsersDB-1" {
  name                = "UsersDB-1"
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  account_name        = azurerm_cosmosdb_account.ifahdevaccount.name
}

resource "azurerm_cosmosdb_mongo_collection" "DBcollection" {
  name                = "DBcollection"
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  account_name        = azurerm_cosmosdb_account.ifahdevaccount.name
  database_name       = azurerm_cosmosdb_mongo_database.UsersDB-1.name

  default_ttl_seconds = "777"
  shard_key           = "uniqueKey"
  throughput          = 400

  index {
    keys   = ["_id"]
    unique = true
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_cosmosdb_account" "gerromeifahaccount" {
  name                = "gerromeifahaccount-${random_integer.ri.result}"
  location            = azurerm_resource_group.DatabaseResourceGroup.location
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.DatabaseResourceGroup.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_role_definition" "Role-Def-Vic" {
  name                = "Role-Def-Vic"
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  account_name        = azurerm_cosmosdb_account.gerromeifahaccount.name
  type                = "CustomRole"
  assignable_scopes   = [azurerm_cosmosdb_account.gerromeifahaccount.id]

  permissions {
    data_actions = ["Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read"]
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "Role-Assignment-Vic" {
  name                = var.object_id
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  account_name        = azurerm_cosmosdb_account.gerromeifahaccount.name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.role-def-vic.id
  principal_id        = data.azurerm_client_config.current.object_id
  scope               = azurerm_cosmosdb_account.gerromeifahaccount.id
}

resource "azurerm_cosmosdb_sql_database" "DB-1" {
  name                = "DB-1"
  resource_group_name = azurerm_resource_group.DatabaseResourceGroup.name
  account_name        = azurerm_cosmosdb_account.gerromeifahaccount.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "Container-1" {
  name                  = "Container-1"
  resource_group_name   = data.azurerm_cosmosdb_account.gerromeifahaccount.resource_group_name
  account_name          = data.azurerm_cosmosdb_account.gerromeifahaccount.name
  database_name         = azurerm_cosmosdb_sql_database.DB-1.name
  partition_key_path    = "/definition/id"
  partition_key_version = 1
  throughput            = 400

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    included_path {
      path = "/included/?"
    }

    excluded_path {
      path = "/excluded/?"
    }
  }

  unique_key {
    paths = ["/definition/idlong", "/definition/idshort"]
  }
}