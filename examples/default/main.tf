terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "> 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

locals {
  bandwidth_in_mbps     = 50
  family                = "MeteredData"
  peering_location      = "Seattle"
  service_provider_name = "Equinix"
  tier                  = "Premium"
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
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# This is the module call
module "exr_circuit_test" {
  source                = "../../"
  resource_group_name   = azurerm_resource_group.this.name
  name                  = module.naming.express_route_circuit.name_unique
  service_provider_name = local.service_provider_name
  peering_location      = local.peering_location
  bandwidth_in_mbps     = local.bandwidth_in_mbps
  location              = azurerm_resource_group.this.location

  sku = {
    tier   = local.tier
    family = local.family
  }

  enable_telemetry = var.enable_telemetry # see variables.tf
}