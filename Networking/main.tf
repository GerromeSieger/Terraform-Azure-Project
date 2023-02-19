resource "azurerm_resource_group" "VicResourceGroup" {
  name     = "VicResourceGroup"
  location = "eastus"
}

resource "azurerm_virtual_network" "VNET-Nepflix-Us" {
  name                = "VNET-Nepflix-Us"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.VicResourceGroup.location
  resource_group_name = azurerm_resource_group.VicResourceGroup.name
}

resource "azurerm_subnet" "Subnet-VM-Servers" {
  name                 = "Subnet-VM-Servers"
  resource_group_name  = azurerm_resource_group.VicResourceGroup.name
  virtual_network_name = azurerm_virtual_network.VNET-Nepflix-Us.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network" "VNET-Nepflix-Subsctiptions" {
  name                = "VNET-Nepflix-Subsctiptions"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.VicResourceGroup.location
  resource_group_name = azurerm_resource_group.VicResourceGroup.name
}

resource "azurerm_subnet" "Subnet-DB-Servers" {
  name                 = "Subnet-DB-Servers"
  resource_group_name  = azurerm_resource_group.VicResourceGroup.name
  virtual_network_name = azurerm_virtual_network.VNET-Nepflix-Subsctiptions.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_virtual_network_peering" "NepflixUS-to-NepflixSUB" {
  name                      = "NepflixUS-to-NepflixSUB"
  resource_group_name       = azurerm_resource_group.VicResourceGroup.name
  virtual_network_name      = azurerm_virtual_network.VNET-Nepflix-Us.name
  remote_virtual_network_id = azurerm_virtual_network.VNET-Nepflix-Subsctiptions.id
}

resource "azurerm_virtual_network_peering" "NepflixSUB-to-NepflixUS" {
  name                      = "NepflixSUB-to-NepflixUS"
  resource_group_name       = azurerm_resource_group.VicResourceGroup.name
  virtual_network_name      = azurerm_virtual_network.VNET-Nepflix-Subsctiptions.name
  remote_virtual_network_id = azurerm_virtual_network.VNET-Nepflix-Us.id
}