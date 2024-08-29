terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  bandwidth_in_mbps     = 50
  family                = "UnlimitedData"
  location              = "East US"
  peering_location      = "Silicon Valley"
  resource_group_name   = "test-erc"
  service_provider_name = "Equinix"
  tier                  = "Standard"
  lock = {
    kind = "ReadOnly"
    name = "exr-lock"
  }
  role_assignments = {
    role1 = {
      principal_id               = azurerm_user_assigned_identity.this.principal_id
      role_definition_id_or_name = "Contributor"
    }
  }
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                           = "sendToLogAnalytics"
      workspace_resource_id          = azurerm_log_analytics_workspace.this.id
      log_analytics_destination_type = "Dedicated"
    }
  }
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.location
  name     = local.resource_group_name
}

# This is required for the user assigned identity
resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.log_analytics_workspace.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "exr_circuit_test" {
  source                = "../../"
  resource_group_name   = azurerm_resource_group.this.name
  name                  = module.naming.express_route_circuit.name
  service_provider_name = local.service_provider_name
  peering_location      = local.peering_location
  bandwidth_in_mbps     = local.bandwidth_in_mbps
  location              = local.location
  lock                  = local.lock
  role_assignments      = local.role_assignments
  diagnostic_settings   = local.diagnostic_settings


  sku = {
    tier   = local.tier
    family = local.family
  }

  enable_telemetry = var.enable_telemetry # see variables.tf
  depends_on       = [azurerm_resource_group.this]
}
