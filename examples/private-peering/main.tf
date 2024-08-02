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
  family                = "MeteredData"
  location              = "West US 2"
  peering_location      = "Seattle"
  resource_group_name   = "SEA-Cust10"
  service_provider_name = "Equinix"
  tier                  = "Premium"
  name                  = "SEA-Cust10-ER"
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


# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "exr_circuit_test" {
  source                = "../../"
  resource_group_name   = local.resource_group_name
  name                  = local.name
  service_provider_name = local.service_provider_name
  peering_location      = local.peering_location
  bandwidth_in_mbps     = local.bandwidth_in_mbps
  location              = local.location

  sku = {
    tier   = local.tier
    family = local.family
  }

  enable_telemetry = var.enable_telemetry # see variables.tf
}
