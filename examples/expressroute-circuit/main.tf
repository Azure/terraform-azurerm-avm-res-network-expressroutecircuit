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
  resource_group_name   = "rg-exr-circuit"
  service_provider_name = "Equinix"
  tier                  = "Standard"
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

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source                = "../../"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  name                  = module.naming.express_route_circuit.name
  service_provider_name = local.service_provider_name
  peering_location      = local.peering_location
  bandwidth_in_mbps     = local.bandwidth_in_mbps

  sku = {
    tier   = local.tier
    family = local.family
  }

  enable_telemetry = var.enable_telemetry # see variables.tf
  depends_on       = [azurerm_resource_group.this]
}
