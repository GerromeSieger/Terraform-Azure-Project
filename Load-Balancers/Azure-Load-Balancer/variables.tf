variable "computer_name_prefix" {
  type        = string
  default     = "ubuntu-vm"
  description = "name of virtual machine"
}

variable "admin_username" {
  type        = string
  default     = "victor"
  description = "name of admin user for the virtual machines"
}

variable "admin_ssh_key_path" {
  type        = string
  default     = "ubuntu-vm"
  description = "name of virtual machine"
}

