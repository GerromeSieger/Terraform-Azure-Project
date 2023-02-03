variable "resource_group_location" {
  default     = "eastus"
  description = "Azure region used for resource deployment"
}

variable "tags" {
  type        =  map(string)
  default     = {
    environment = "dev"
  }
  description = "Tags"
}

variable "resource_group_name" {
  default     = "KubernetesResourceGroup"
  description = "Name of the resource group container for all resources"
}

variable "cluster_name" {
  default     = "k8s-cluster-dev"
  description = "Name of the kubernetes cluster"
}

variable "prefix" {
  default     = "k8s-dev"
  description = "Name of the k8s cluster prefix"
}

variable "admin_username" {
  default     = "gerrome"
  description = "User name for the node pools"
}

variable "agents_count" {
  default     = 2
  description = "Number of worker nodes"
}

variable "rbac_aad_client_app_id" {
  default     = "ed2a0303-2094-4d5d-b672-5d640b44c58a"
  description = "The client Id"
}

variable "rbac_aad_server_app_id" {
  default     = "d6f8a881-046f-4969-a852-b4a0677740af"
  description = "The server Id"
}

variable "rbac_aad_server_app_secret" {
  default     = "-wI8Q~kw9HFozzN8cby_7bmrxGZfBmZzVPo2XbpZ"
  description = "The the server secret"
}

variable "rbac_aad_tenant_id" {
  default     = "cff0df93-2420-4445-b95e-10f7d7eb49e1"
  description = "The tenant Id"
}


