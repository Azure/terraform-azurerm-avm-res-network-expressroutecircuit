terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "none"
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
module "avm_utl_regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.5.2"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.avm_utl_regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.avm_utl_regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# This is the module call
module "exr_circuit_test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.express_route_circuit.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku = {
    tier   = local.tier
    family = local.family
  }
  bandwidth_in_mbps     = local.bandwidth_in_mbps
  enable_telemetry      = var.enable_telemetry # see variables.tf
  peering_location      = local.peering_location
  service_provider_name = local.service_provider_name
}
