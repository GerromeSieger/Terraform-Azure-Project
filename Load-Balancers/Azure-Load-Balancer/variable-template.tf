variable "computer_name_prefix" {
  type        = string
  default     = ""
  description = "name of virtual machine"
}

variable "admin_username" {
  type        = string
  default     = ""
  description = "name of admin user for the virtual machines"
}

variable "admin_ssh_key_path" {
  type        = string
  default     = ""
  description = "path to the ssh public key"
}

