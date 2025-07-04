<!-- BEGIN_TF_DOCS -->
# Azure ExpressRoute Circuit Module - Complete Example

This example demonstrates how to deploy an Azure ExpressRoute Circuit along with all its dependencies, including peerings (both private and Microsoft public with dual-stack IPv4/IPv6), circuit authorizations, and connections to both Virtual Network Gateway and ExpressRoute Gateway.

## This example will provision the following resources:

 - ExpressRoute Circuit: The core resource that enables private, high-bandwidth connections to Azure services.
 - Private and Public Peerings: Both private peering (for connecting on-premises resources to Azure virtual networks) and Microsoft peering (for connecting to Microsoft services such as Office 365) are configured with IPv4 and IPv6 addresses.
 - Circuit Authorizations: Grants authorization for Azure subscriptions to connect to the circuit.
 - VNet Gateway Connection: Establishes a connection between the ExpressRoute circuit and the Azure Virtual Network using a Virtual Network Gateway.
- ExpressRoute Gateway Connection: Connects the circuit to an ExpressRoute Gateway for broader network infrastructure (typically used in Virtual WAN deployments).

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
  subscription_id = local.subscription_id
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
  location              = "West US 2"
  name                  = "SEA-Cust10-ER"
  peering_location      = "Seattle"
  resource_group_name   = "SEA-Cust10"
  service_provider_name = "Equinix"
  subscription_id       = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  tier                  = "Premium"
  vng_gw_conn_name      = "vng-gw-conn"
  vng_gw_id             = "/subscriptions/${local.subscription_id}/resourceGroups/SEA-Cust10/providers/Microsoft.Network/virtualNetworkGateways/er-gateway"
  vng_gw_peering_id     = "/subscriptions/${local.subscription_id}/resourceGroups/SEA-Cust10/providers/Microsoft.Network/expressRouteCircuits/SEA-Cust10-ER/peerings/AzurePrivatePeering"
  vwan_gw_id            = "/subscriptions/${local.subscription_id}/resourceGroups/SEA-Cust10/providers/Microsoft.Network/expressRouteGateways/3f15552377fc4e1ca55ac58af5d7a67e-westus2-er-gw"
  vwan_hub_id           = "/subscriptions/${local.subscription_id}/resourceGroups/SEA-Cust10/providers/Microsoft.Network/virtualHubs/wus2-hub"
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


# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "exr_circuit_test" {
  source = "../../"

  location            = local.location
  name                = local.name
  resource_group_name = local.resource_group_name
  sku = {
    tier   = local.tier
    family = local.family
  }
  bandwidth_in_mbps = local.bandwidth_in_mbps
  enable_telemetry  = var.enable_telemetry # see variables.tf
  er_gw_connections = {
    connection-er = {
      name                                      = "ExRConnection-westus2-er"
      express_route_gateway_resource_id         = local.vwan_gw_id
      express_route_circuit_peering_resource_id = local.vng_gw_peering_id
      peering_map_key                           = "firstPeeringConfig" # References the map key of the private peering as defined above in the peerings block, you could alternatively supply the explicit peering resource ID with the variable `express_route_circuit_peering_resource_id`.
      routeting_weight                          = 0
      express_route_gateway_bypass_enabled      = true
      routing = {
        inbound_route_map_resource_id  = azurerm_route_map.in.id
        outbound_route_map_resource_id = azurerm_route_map.out.id
        propagated_route_table = {
          route_table_resource_ids = [
            azurerm_virtual_hub_route_table.example.id,
            azurerm_virtual_hub_route_table.additional.id
          ]
        }
      }
    }
  }
  express_route_circuit_authorizations = {
    authorization1 = {
      name = "authorization1"
    },
    authorization2 = {
      name = "authorization2"
    }
  }
  peering_location = local.peering_location
  peerings = {
    firstPeeringConfig = {
      peering_type                  = "AzurePrivatePeering"
      peer_asn                      = 64512
      primary_peer_address_prefix   = "10.0.0.0/30"
      secondary_peer_address_prefix = "10.0.0.4/30"
      ipv4_enabled                  = true
      vlan_id                       = 300
      shared_key                    = "A1B2C3D4E5F6"

      ipv6 = {
        primary_peer_address_prefix   = "2002:db01::/126"
        secondary_peer_address_prefix = "2003:db01::/126"
        enabled                       = true
      }
    }
    secondPeeringConfig = {
      peering_type                  = "MicrosoftPeering"
      peer_asn                      = 200
      primary_peer_address_prefix   = "123.0.0.0/30"
      secondary_peer_address_prefix = "123.0.0.4/30"
      ipv4_enabled                  = true
      vlan_id                       = 400

      microsoft_peering_config = {
        advertised_public_prefixes = ["123.1.0.0/24"]
      }

      ipv6 = {
        primary_peer_address_prefix   = "2002:db01::/126"
        secondary_peer_address_prefix = "2003:db01::/126"
        enabled                       = true

        microsoft_peering = {
          advertised_public_prefixes = ["2002:db01::/126"]
        }
      }
    }
  }
  service_provider_name = local.service_provider_name
  vnet_gw_connections = {
    connection-gw = {
      name                                = local.vng_gw_conn_name
      virtual_network_gateway_resource_id = local.vng_gw_id
      location                            = local.location
      resource_group_name                 = local.resource_group_name
      express_route_gateway_bypass        = true
      private_link_fast_path_enabled      = true
    }
  }
}

# Create a Route Table (Primary)
resource "azurerm_virtual_hub_route_table" "example" {
  name           = "example-route-table"
  virtual_hub_id = local.vwan_hub_id
}

# Create an additional Route Table (Propagated)
resource "azurerm_virtual_hub_route_table" "additional" {
  name           = "additional-route-table"
  virtual_hub_id = local.vwan_hub_id
}

# Test rout map for association to connection
resource "azurerm_route_map" "in" {
  name           = "example-rm-in"
  virtual_hub_id = local.vwan_hub_id

  rule {
    name                 = "rule1"
    next_step_if_matched = "Continue"

    action {
      type = "Add"

      parameter {
        as_path = ["22334"]
      }
    }
    match_criterion {
      match_condition = "Contains"
      route_prefix    = ["10.0.0.0/8"]
    }
  }
}

# Test rout map for association to connection
resource "azurerm_route_map" "out" {
  name           = "example-rm-out"
  virtual_hub_id = local.vwan_hub_id

  rule {
    name                 = "rule1"
    next_step_if_matched = "Terminate"

    action {
      type = "Replace"

      parameter {
        community = ["22"]
      }
    }
    match_criterion {
      match_condition = "NotContains"
      route_prefix    = ["10.0.0.0/8"]
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

- [azurerm_route_map.in](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_map) (resource)
- [azurerm_route_map.out](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_map) (resource)
- [azurerm_virtual_hub_route_table.additional](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_route_table) (resource)
- [azurerm_virtual_hub_route_table.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_route_table) (resource)
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

Version: ~> 0.3.0

### <a name="module_exr_circuit_test"></a> [exr\_circuit\_test](#module\_exr\_circuit\_test)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->