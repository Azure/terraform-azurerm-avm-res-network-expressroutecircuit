<!-- BEGIN_TF_DOCS -->
# Azure ExpressRoute Circuit Module - with Global Reach
This example demonstrates how to deploy multiple circuits and connect them with [Global Reach](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-global-reach).

## This example will deploy:
 - Deploy two ExpressRoute Direct ports
 - Deploy two ExpressRoute Circuits connected to the port.
 - Deploy Private Peerings
 - Connect between the circuits

```hcl
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_express_route_port.erd_port_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_port) (resource)
- [azurerm_express_route_port.erd_port_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_port) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm_utl_regions"></a> [avm\_utl\_regions](#module\_avm\_utl\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: 0.5.2

### <a name="module_er_circuit_1"></a> [er\_circuit\_1](#module\_er\_circuit\_1)

Source: ../../

Version:

### <a name="module_er_circuit_2"></a> [er\_circuit\_2](#module\_er\_circuit\_2)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.2

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->