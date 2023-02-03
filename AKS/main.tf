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

resource "azurerm_resource_group" "KubernetesResourceGroup" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = var.tags

}

module "k8s" {
  source = "Azure/aks/azurerm"

  cluster_name                      = var.cluster_name
  resource_group_name               = azurerm_resource_group.Kubernetes-Resource-Group.name
  location                          = azurerm_resource_group.Kubernetes-Resource-Group.location
  prefix                            = var.prefix
  agents_count                      = var.agents_count
  admin_username                    = var.admin_username
  role_based_access_control_enabled = true
  rbac_aad_client_app_id            = var.rbac_aad_client_app_id
  rbac_aad_server_app_id            = var.rbac_aad_server_app_id 
  rbac_aad_server_app_secret        = var.rbac_aad_server_app_secret
  rbac_aad_tenant_id                = var.rbac_aad_tenant_id
}

