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

resource "azurerm_resource_group" "LoadBalancerResourceGroup" {
  name     = "LoadBalancerResourceGroup"
  location = "eastus"
}

resource "azurerm_service_plan" "TorAppUS" {
  name                = "TorAppUS"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  os_type             = "Windows"
  sku_name            = "P1v2"
}

resource "azurerm_service_plan" "TorAppUK" {
  name                = "TorAppUK"
  location            = "ukwest"
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  os_type             = "Windows"
  sku_name            = "P1v2"
}

resource "azurerm_windows_web_app" "TorUS" {
  name                = "TorUS"
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  location            = azurerm_service_plan.TorAppUS.location
  service_plan_id     = azurerm_service_plan.TorAppUS.id

  site_config {}
}

resource "azurerm_windows_web_app" "TorUK" {
  name                = "TorUK"
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  location            = "ukwest"
  service_plan_id     = azurerm_service_plan.TorAppUK.id

  site_config {}
}

resource "azurerm_frontdoor" "AZ-FrontDoor" {
  name                = "AZ-FrontDoor"
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  routing_rule {
    name               = "Rule1"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["frontend-endpoint"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "backend-pool"
    }
  }

  backend_pool_load_balancing {
    name = "backend-pool-lb"
  }

  backend_pool_health_probe {
    name = "backend-pool-health-probe"
  }

  backend_pool {
    name = "backend-pool"
    backend {
      host_header = "TorUS.azurewebsites.net"
      address     = "TorUS.azurewebsites.net"
      http_port   = 80
      https_port  = 443
    }

    backend {
      host_header = "TorUK.azurewebsites.net"
      address     = "TorUK.azurewebsites.net"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "backend-pool-lb"
    health_probe_name   = "backend-pool-health-probe"
  }

  frontend_endpoint {
    name      = "frontend-endpoint"
    host_name = "AZ-FrontDoor.azurefd.net"
  }
}
