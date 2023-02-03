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

resource "azurerm_virtual_network" "VNET-1" {
  name                = "VNET-1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
}

resource "azurerm_subnet" "Frontend-Subnet" {
  name                 = "Frontend-Subnet"
  resource_group_name  = azurerm_resource_group.LoadBalancerResourceGroup.name
  virtual_network_name = azurerm_virtual_network.VNET-1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_app_service_plan" "AppPlan" {
  name                = "AppPlan"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "App1" {
  name                = "App1"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  app_service_plan_id = azurerm_app_service_plan.AppPlan.id
}

resource "azurerm_app_service" "App2" {
  name                = "App2"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  app_service_plan_id = azurerm_app_service_plan.AppPlan.id
}

resource "azurerm_public_ip" "AGW-PublicIP" {
  name                = "AGW-PublicIP"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "App-Gateway" {
  name                = "App-Gateway"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name

  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 2
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "subnet"
    subnet_id = azurerm_subnet.Frontend-Subnet.id
  }

  frontend_ip_configuration {
    name                 = "Frontend-Ip-Config"
    public_ip_address_id = azurerm_public_ip.AGW-PublicIP.id
  }

  frontend_port {
    name = "Frontend-Port"
    port = 80
  }

  backend_address_pool {
    name  = "AppService"
    fqdns = ["${azurerm_app_service.App1.name}.azurewebsites.net", "${azurerm_app_service.App2.name}.azurewebsites.net"]
  }

  backend_http_settings {
    name                                = "backend-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 1
    probe_name                          = "probe"
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "Frontend-Ip-Config"
    frontend_port_name             = "Frontend-Port"
    protocol                       = "Http"
  }

  probe {
    name                = "probe"
    protocol            = "Http"
    path                = "/"
    host                = "${azurerm_app_service_plan.AppPlan.name}.azurewebsites.net"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  request_routing_rule {
    name                       = "http"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "AppService"
    backend_http_settings_name = "backend-http-settings"
  }
}