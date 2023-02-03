variable "resource_group_location" {
  default     = ""
  description = "Azure region used for resource deployment"
}

variable "tags" {
  type        =  map(string)
  default     = {
    environment = ""
  }
  description = "Tags"
}

variable "resource_group_name" {
  default     = ""
  description = "Name of the resource group container for all resources"
}

variable "cluster_name" {
  default     = ""
  description = "Name of the kubernetes cluster"
}

variable "prefix" {
  default     = ""
  description = "Name of the k8s cluster prefix"
}

variable "admin_username" {
  default     = ""
  description = "User name for the nodes"
}

variable "agents_count" {
  default     = 2
  description = "Number of worker nodes"
}

variable "rbac_aad_client_app_id" {
  default     = ""
  description = "The client Id"
}

variable "rbac_aad_server_app_id" {
  default     = ""
  description = "The server Id"
}

variable "rbac_aad_server_app_secret" {
  default     = ""
  description = "The the server secret"
}

variable "rbac_aad_tenant_id" {
  default     = ""
  description = "The tenant Id"
}


