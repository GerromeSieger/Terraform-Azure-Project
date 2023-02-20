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

resource "azurerm_resource_group" "VicResourceGroup" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "VNET-1" {
  name                = var.virtual_network_name
  address_space       = var.virtual_network_address_space
  location            = azurerm_resource_group.VicResourceGroup.location
  resource_group_name = azurerm_resource_group.VicResourceGroup.name
}

resource "azurerm_subnet" "Subnet-1" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.VicResourceGroup.name
  virtual_network_name = azurerm_virtual_network.VNET-1.name
  address_prefixes     = var.subnet_prefixes
}

resource "azurerm_public_ip" "PublicIP-1" {
  name                = var.public_ip
  resource_group_name = azurerm_resource_group.VicResourceGroup.name
  location            = azurerm_resource_group.VicResourceGroup.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "NIC-1" {
  name                = var.network_interface
  location            = azurerm_resource_group.VicResourceGroup.location
  resource_group_name = azurerm_resource_group.VicResourceGroup.name

  ip_configuration {
    name                          = var.ip_configuration
    subnet_id                     = azurerm_subnet.Subnet-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PublicIP-1.id
  }
}


resource "azurerm_network_security_group" "Vic-NSG" {
  name                = var.network_security_group
  location            = azurerm_resource_group.VicResourceGroup.location
  resource_group_name = azurerm_resource_group.VicResourceGroup.name
}

resource "azurerm_network_security_rule" "vic-nsg-rule-1" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.VicResourceGroup.name
  network_security_group_name = azurerm_network_security_group.Vic-NSG.name
}

resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id      = azurerm_network_interface.NIC-1.id
  network_security_group_id = azurerm_network_security_group.Vic-NSG.id
}

resource "azurerm_storage_account" "storageaccountgerrome" {
  name                     = var.storage_account
  resource_group_name      = azurerm_resource_group.VicResourceGroup.name
  location                 = azurerm_resource_group.VicResourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "Dev-Server" {
  name                  = var.linux_virtual_machine_name
  location              = azurerm_resource_group.VicResourceGroup.location
  resource_group_name   = azurerm_resource_group.VicResourceGroup.name
  network_interface_ids = [azurerm_network_interface.NIC-1.id]
  size                  = "Standard_B1s"
  computer_name         = var.computer_name
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_sshkey_path)
  }

  os_disk {
    name                 = var.os_disk
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
