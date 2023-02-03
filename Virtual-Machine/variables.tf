variable "resource_group_name" {
  default     = "VicResourceGroup"
  description = "Name of the resource group container for all resources"
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Azure region used for resource deployment"
}

variable "virtual_network_name" {
  default     = "VNET-1"
  description = "Name of the virtual network"
}

variable "virtual_network_address_space" {
  default     = ["10.1.0.0/16"]
  description = "The virtual network address space"
}

variable "subnet_name" {
  default     = "Subnet-1"
  description = "Name of the first subnet"
}

variable "subnet_prefixes" {
  default     = ["10.1.1.0/24"]
  description = "The subnet address space"
}

variable "public_ip" {
  default     = "PublicIP-1"
  description = "Name of the first public ip address"
}

variable "network_interface" {
  default     = "NIC-1"
  description = "Name of the Network interface"
}

variable "ip_configuration" {
  default  = "ip-config-1"
  description = "The name of the ip configuration for the network interface"  
}

variable "network_security_group" {
  default     = "Vic-NSG"
  description = "Name of the Network security group"
} 

variable "storage_account" {
  default     = "storageaccountgerrome"
  description = "Name of the Storage account"
}

variable "linux_virtual_machine_name" {
  default     = "Dev-Server"
  description = "Name of the Virtual machine"
}

variable "computer_name" {
  default     = "server-vm"
  description = "Name of the os computer"
}

variable "admin_username" {
  default     = "gerrome"
  description = "User name for the Virtual Machine"
}

variable "admin_password" {
  default     = "Ifah6354!"
  description = "Password for the Virtual Machine."
}

variable "admin_sshkey_path" {
  type        = string
  default     = "~/.ssh/azurevmkey.pub"
  description = "SSH key for authentication to the Virtual Machines"
}

variable "os_disk" {
  default     = "dev-vm-disk"
  description = "Name of the os disk"
}
