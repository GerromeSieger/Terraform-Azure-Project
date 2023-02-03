variable "resource_group_name" {
  default     = ""
  description = "Name of the resource group container for all resources"
}

variable "resource_group_location" {
  default     = ""
  description = "Azure region used for resource deployment"
}

variable "virtual_network_name" {
  default     = ""
  description = "Name of the virtual network"
}

variable "virtual_network_address_space" {
  default     = [""]
  description = "The virtual network address space or cidr"
}

variable "subnet_name" {
  default     = ""
  description = "Name of the first subnet"
}

variable "subnet_prefixes" {
  default     = [""]
  description = "The subnet address space"
}

variable "public_ip" {
  default     = ""
  description = "Name of the first public ip address"
}

variable "network_interface" {
  default     = ""
  description = "Name of the Network interface"
}

variable "ip_configuration" {
  default  = ""
  description = "The name of the ip configuration for the network interface"  
}

variable "network_security_group" {
  default     = ""
  description = "Name of the Network security group"
} 

variable "storage_account" {
  default     = ""
  description = "Name of the Storage account"
}

variable "linux_virtual_machine_name" {
  default     = ""
  description = "Name of the Virtual machine"
}

variable "computer_name" {
  default     = ""
  description = "Name of the os computer"
}

variable "admin_username" {
  default     = ""
  description = "User name for the Virtual Machine"
}

variable "admin_password" {
  default     = ""
  description = "Password for the Virtual Machine."
}

variable "admin_sshkey_path" {
  type        = string
  default     = "path"
  description = "SSH key for authentication to the Virtual Machines"
}

variable "os_disk" {
  default     = ""
  description = "Name of the os disk"
}
