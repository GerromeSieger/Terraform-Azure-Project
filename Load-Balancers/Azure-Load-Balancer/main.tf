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

resource "azurerm_virtual_network" "LoadBalancerResourceGroup" {
  name                = "VNET-2"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
}

resource "azurerm_subnet" "VMSS-Subnet" {
  name                 = "VMSS-Subnet"
  resource_group_name  = azurerm_resource_group.LoadBalancerResourceGroup.name
  virtual_network_name = azurerm_virtual_network.VNET-2.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "ALB-PublicIP" {
  name                = "ALB-PublicIP"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "Azure-Load-Balancer" {
  name                = "Azure-Load-Balancer"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name

  frontend_ip_configuration {
    name                 = "FrontendIP"
    public_ip_address_id = azurerm_public_ip.ALB-PublicIP.id
  }
}

resource "azurerm_lb_backend_address_pool" "BackendPool" {
  name            = "BackendPool"
  loadbalancer_id = azurerm_lb.Azure-Load-Balancer.id
}

resource "azurerm_lb_probe" "HealthProbe" {
  name            = "HealthProbe"
  loadbalancer_id = azurerm_lb.Azure-Load-Balancer.id

  port = 80

  interval_in_seconds = 15

  number_of_probes = 3
}

resource "azurerm_lb_rule" "LB-Rule-1" {
  name            = "LB-Rule-1"
  loadbalancer_id = azurerm_lb.azure-load-balancer.id

  frontend_port = 80
  backend_port  = 80

  protocol = "Tcp"

  frontend_ip_configuration_name = "FrontendIP"

  backend_address_pool_ids = [azurerm_lb_backend_address_pool.BackendPool.id]
  probe_id                 = azurerm_lb_probe.HealthProbe.id
}

resource "azurerm_storage_account" "storageaccountgerrome" {
  name                     = "storageaccountgerrome"
  resource_group_name      = azurerm_resource_group.LoadBalancerResourceGroup.name
  location                 = azurerm_resource_group.LoadBalancerResourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine_scale_set" "VM-ScaleSet" {
  name                 = "VM-ScaleSet"
  location             = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name  = azurerm_resource_group.LoadBalancerResourceGroup.name
  sku                  = "Standard_B2s"
  computer_name_prefix = var.computer_name_prefix
  admin_username       = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_key_path)
  }

  network_interface {
    name    = "NIC-1"
    primary = true
    
    ip_configuration {
      name                 = "Ip-Config"
      subnet_id            = azurerm_subnet.VMSS-Subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.BackendPool.id]
    }    
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  count = 2 

}
