terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.40.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30.0"
    }    
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "ad-demo" {
    name = "ad-demo" 
    location = "eastus"
}

resource "azuread_user" "Lionel_Messi" {
  user_principal_name   = "lionelmessi@vsifahoutlook.onmicrosoft.com"
  display_name          = "Lionel_Messi"
  department            = "Frontend-Team"
  password              = var.messi_password
  force_password_change = true
}

resource "azuread_user" "Neymar_Jr" {
  user_principal_name   = "neymarjr@vsifahoutlook.onmicrosoft.com"
  display_name          = "Neymar_Jr"
  department            = "Backend-Team"
  password              = var.neymar_password
  force_password_change = true
}

# Provision Azure AD Groups
data "azuread_client_config" "current" {}

resource "azuread_group" "Readers" {
  display_name = "Readers"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "user.userPrincipalName -contains \"vsifahoutlook.onmicrosoft.com\""
  }
}

resource "azuread_group" "Backend-Team" {
  display_name     = "Backend-Team"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "user.department -eq \"Backend-Team\""
  }
}

resource "azuread_group" "Frontend-Team" {
  display_name     = "Frontend-Team"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "user.department -eq \"Frontend-Team\""
  }
}

# Azure AD Conditional Access Policy
resource "azuread_conditional_access_policy" "Frontend_access_policy" {
  display_name = "Frontend team access policy"
  state        = "enabled"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
      excluded_applications = []
    }

    users {
      included_groups = [azuread_group.Frontend-Team.id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}
