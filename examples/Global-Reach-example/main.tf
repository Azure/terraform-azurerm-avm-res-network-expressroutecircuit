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
  bandwidth_in_gbps     = 10
  encapsulation         = "Dot1Q"
  erc1_name             = "circuit_office_1"
  erc2_name             = "circuit_office_2"
  erd1_peering_location = "Equinix-Amsterdam-AM5"
  erd1_port_name        = "erd_port_office_1"
  erd2_peering_location = "Equinix-London-LD5"
  erd2_port_name        = "erd_port_office_2"
  family                = "MeteredData"
  tier                  = "Premium"
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "avm_utl_regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.3.0"
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
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.avm_utl_regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# Express Route Direct Port 1
resource "azurerm_express_route_port" "erd_port_1" {
  bandwidth_in_gbps   = local.bandwidth_in_gbps
  encapsulation       = local.encapsulation
  location            = azurerm_resource_group.this.location
  name                = local.erd1_port_name
  peering_location    = local.erd1_peering_location
  resource_group_name = azurerm_resource_group.this.name

  link1 {
    admin_enabled = false
    macsec_cipher = "GcmAes256"
  }
  link2 {
    admin_enabled = false
    macsec_cipher = "GcmAes256"
  }
}

# Express Route Direct Port 2
resource "azurerm_express_route_port" "erd_port_2" {
  bandwidth_in_gbps   = local.bandwidth_in_gbps
  encapsulation       = local.encapsulation
  location            = azurerm_resource_group.this.location
  name                = local.erd2_port_name
  peering_location    = local.erd2_peering_location
  resource_group_name = azurerm_resource_group.this.name

  link1 {
    admin_enabled = false
    macsec_cipher = "GcmAes256"
  }
  link2 {
    admin_enabled = false
    macsec_cipher = "GcmAes256"
  }
}

# Circuit 1 creation
module "er_circuit_1" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = local.erc1_name
  resource_group_name = azurerm_resource_group.this.name
  sku = {
    tier   = local.tier
    family = local.family
  }
  bandwidth_in_gbps = 10
  circuit_connections = {
    west_eu_to_north_eu = {
      name                     = "globalreach_ams_to_uk"
      peer_map_key             = "PrivatePeeringConfig" # References the map key of the private peering as defined above in the peerings block, you could alternatively supply the explicit peering resource ID with the variable `peer_resource_id`.
      peer_peering_resource_id = module.er_circuit_2.peerings["PrivatePeeringConfig"].id
      address_prefix_ipv4      = "192.168.8.0/29"
    }
  }
  enable_telemetry               = var.enable_telemetry # see variables.tf
  express_route_port_resource_id = azurerm_express_route_port.erd_port_1.id
  peerings = {
    PrivatePeeringConfig = {
      peering_type                  = "AzurePrivatePeering"
      peer_asn                      = 64512
      primary_peer_address_prefix   = "10.0.0.0/30"
      secondary_peer_address_prefix = "10.0.0.4/30"
      ipv4_enabled                  = true
      vlan_id                       = 300
    }
  }
}

# Circuit 2 creation
module "er_circuit_2" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = local.erc2_name
  resource_group_name = azurerm_resource_group.this.name
  sku = {
    tier   = local.tier
    family = local.family
  }
  bandwidth_in_gbps              = 10
  enable_telemetry               = var.enable_telemetry # see variables.tf
  express_route_port_resource_id = azurerm_express_route_port.erd_port_2.id
  peerings = {
    PrivatePeeringConfig = {
      peering_type                  = "AzurePrivatePeering"
      peer_asn                      = 64513
      primary_peer_address_prefix   = "10.1.0.0/30"
      secondary_peer_address_prefix = "10.1.0.4/30"
      ipv4_enabled                  = true
      vlan_id                       = 400
    }
  }
}