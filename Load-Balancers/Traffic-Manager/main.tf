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

resource "azurerm_resource_group" "LoadBalancerResourceGroupUK" {
  name     = "LoadBalancerResourceGroupUK"
  location = "ukwest"
}

resource "azurerm_virtual_network" "VNET-US" {
  name                = "VNET-US"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
}

resource "azurerm_subnet" "Subnet-1" {
  name                 = "Subnet-1"
  resource_group_name  = azurerm_resource_group.LoadBalancerResourceGroup.name
  virtual_network_name = azurerm_virtual_network.VNET-US.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "PublicIP-VM1" {
  name                = "PublicIP-VM1"
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "Nic-VM1" {
  name                = "Nic-VM1"
  location            = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name

  ip_configuration {
    name                          = "ip-config"
    subnet_id                     = azurerm_subnet.Subnet-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PublicIP-VM1.id
  }
}

resource "azurerm_storage_account" "storageaccountgerrome" {
  name                     = "storageaccountgerrome"
  resource_group_name      = azurerm_resource_group.LoadBalancerResourceGroup.name
  location                 = azurerm_resource_group.LoadBalancerResourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "Dev-Server-US" {
  name                  = "Dev-Server-US"
  location              = azurerm_resource_group.LoadBalancerResourceGroup.location
  resource_group_name   = azurerm_resource_group.LoadBalancerResourceGroup.name
  network_interface_ids = [azurerm_network_interface.Nic-VM1.id]
  size                  = "Standard_B1s"
  computer_name         = var.computer_name
  admin_username        = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_key_path)
  }

  os_disk {
    name                 = "dev-vm-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

#second vm

resource "azurerm_virtual_network" "VNET-UK" {
  name                = "VNET-UK"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.LoadBalancerResourceGroupUK.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroupUK.name
}

resource "azurerm_subnet" "Subnet-2" {
  name                 = "Subnet-2"
  resource_group_name  = azurerm_resource_group.LoadBalancerResourceGroupUK.name
  virtual_network_name = azurerm_virtual_network.VNET-UK.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "PublicIP-VM2" {
  name                = "PublicIP-VM2"
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroupUK.name
  location            = azurerm_resource_group.LoadBalancerResourceGroupUK.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "Nic-VM2" {
  name                = "Nic-VM2"
  location            = azurerm_resource_group.LoadBalancerResourceGroupUK.location
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroupUK.name

  ip_configuration {
    name                          = "ip-config"
    subnet_id                     = azurerm_subnet.Subnet-2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PublicIP-VM2.id
  }
}

resource "azurerm_storage_account" "storageaccountvictorifah" {
  name                     = "storageaccountvictorifah"
  resource_group_name      = azurerm_resource_group.LoadBalancerResourceGroupUK.name
  location                 = azurerm_resource_group.LoadBalancerResourceGroupUK.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "Dev-Server-UK" {
  name                  = "Dev-Server-UK"
  location              = azurerm_resource_group.LoadBalancerResourceGroupUK.location
  resource_group_name   = azurerm_resource_group.LoadBalancerResourceGroupUK.name
  network_interface_ids = [azurerm_network_interface.Nic-VM2.id]
  size                  = "Standard_B1s"
  computer_name         = var.computer_name
  admin_username        = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_key_path)
  }

  os_disk {
    name                 = "dev-vm-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_dns_zone" "DNS-Zone-US" {
  name                = "us-dev-vm.com"
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
}

resource "azurerm_dns_a_record" "dns-record-1" {
  name                = "dns-record-1"
  zone_name           = azurerm_dns_zone.DNS-Zone-US.name
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroup.name
  ttl                 = 300
  records             = [var.public_ip_address_us]
}

resource "azurerm_dns_zone" "DNS-Zone-UK" {
  name                = "uk-dev-vm.com"
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroupUK.name
}

resource "azurerm_dns_a_record" "dns-record-2" {
  name                = "dns-record-2"
  zone_name           = azurerm_dns_zone.DNS-Zone-UK.name
  resource_group_name = azurerm_resource_group.LoadBalancerResourceGroupUK.name
  ttl                 = 300
  records             = [var.public_ip_address_uk]
}

resource "azurerm_traffic_manager_profile" "Traffic-Manager" {
  name                   = "Traffic-Manager"
  resource_group_name    = azurerm_resource_group.LoadBalancerResourceGroup.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "dev-tm"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_external_endpoint" "end-point-1" {
  name       = "end-point-1"
  profile_id = azurerm_traffic_manager_profile.Traffic-Manager.id
  weight     = 100
  target     = "us-dev-vm.com"
}

resource "azurerm_traffic_manager_external_endpoint" "end-point-2" {
  name       = "end-point-2"
  profile_id = azurerm_traffic_manager_profile.Traffic-Manager.id
  weight     = 100
  target     = "uk-dev-vm.com"
}