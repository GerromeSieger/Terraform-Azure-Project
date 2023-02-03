variable "computer_name" {
  type        = string
  default     = "ubuntu-vm"
  description = "name of virtual machine"
}

variable "admin_username" {
  type        = string
  default     = "victor"
  description = "name of admin user for the virtual machine"
}

variable "admin_ssh_key_path" {
  type        = string
  default     = "ubuntu-vm"
  description = "name of virtual machine"
}

variable "public_ip_address_us"{
    default = 
    description = "public ip address of the first VM"
}

variable "public_ip_address_uk"{
    default = 
    description = "public ip address of the second VM"
}
