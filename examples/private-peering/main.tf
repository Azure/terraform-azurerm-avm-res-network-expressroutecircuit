terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.99.0"
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
  location              = "West US 2"
  peering_location      = "Seattle"
  resource_group_name   = "SEA-Cust10"
  service_provider_name = "Equinix"
  tier                  = "Premium"
  name                  = "SEA-Cust10-ER"
  same_rg_conn_name     = "same_rg_connection"
  same_rg_gw_id         = "/subscriptions/4bffbb15-d414-4874-a2e4-c548c6d45e2a/resourceGroups/SEA-Cust10/providers/Microsoft.Network/virtualNetworkGateways/er-gateway"
  same_rg_er_gw_id      = "/subscriptions/4bffbb15-d414-4874-a2e4-c548c6d45e2a/resourceGroups/SEA-Cust10/providers/Microsoft.Network/expressRouteGateways/56baea672a39485b969fdd25f5832098-westus2-er-gw"
  same_rg_er_peering_id = "/subscriptions/4bffbb15-d414-4874-a2e4-c548c6d45e2a/resourceGroups/SEA-Cust10/providers/Microsoft.Network/expressRouteCircuits/SEA-Cust10-ER/peerings/AzurePrivatePeering"
  vwh_id                = "/subscriptions/4bffbb15-d414-4874-a2e4-c548c6d45e2a/resourceGroups/SEA-Cust10/providers/Microsoft.Network/virtualHubs/wus2-hub"
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

  peerings = {
    firstPeeringConfig = {
      peering_type                  = "AzurePrivatePeering"
      peer_asn                      = 64512
      primary_peer_address_prefix   = "10.0.0.0/30"
      secondary_peer_address_prefix = "10.0.0.4/30"
      ipv4_enabled                  = true
      vlan_id                       = 300

      ipv6 = {
        primary_peer_address_prefix   = "2002:db01::/126"
        secondary_peer_address_prefix = "2003:db01::/126"
        enabled                       = true
      }
    }
    # ,
    # secondPeeringConfig = {
    #   peering_type                  = "MicrosoftPeering"
    #   peer_asn                      = 200
    #   primary_peer_address_prefix   = "123.0.0.0/30"
    #   secondary_peer_address_prefix = "123.0.0.4/30"
    #   ipv4_enabled                  = true
    #   vlan_id                       = 400

    #   microsoft_peering_config = {
    #     advertised_public_prefixes = ["123.1.0.0/24"]
    #   }

    #   ipv6 = {
    #     primary_peer_address_prefix   = "2002:db01::/126"
    #     secondary_peer_address_prefix = "2003:db01::/126"
    #     enabled                       = true

    #     microsoft_peering = {
    #       advertised_public_prefixes = ["2002:db01::/126"]
    #     }
    #   }
    # }
  }

  express_route_circuit_authorizations = {
    authorization1 = {
      name = "authorization1"
    }
  }

  vnet_gw_connections = {
    connection1gw = {
      name                       = local.same_rg_conn_name
      virtual_network_gateway_id = local.same_rg_gw_id
      location                   = local.location
      resource_group_name        = local.resource_group_name
    }
  }


#  routing = optional(object({
#       associated_route_table_id = string
#       inbound_route_map_id      = string
#       outbound_route_map_id     = string
#       propagated_route_table = object({
#         labels          = list(string)
#         route_table_ids = list(string)
#       })
#     }), null)



  er_gw_connections = {
    connection1er = {
      name                             = "ExRConnection-westus2-er"
      express_route_gateway_id         = local.same_rg_er_gw_id
      #express_route_circuit_peering_id = local.same_rg_er_peering_id
      peering_map_key = "firstPeeringConfig"
      routeting_weight = 0
      routing = {
        #associated_route_table_id    = azurerm_virtual_hub_route_table.example.id
        inbound_route_map_id         = azurerm_route_map.in.id
        outbound_route_map_id        = azurerm_route_map.out.id
        propagated_route_table = {
          route_table_ids = [
            azurerm_virtual_hub_route_table.example.id,
            azurerm_virtual_hub_route_table.additional.id
          ]
        }
        static_routes = {
          address_prefix = "10.1.0.0/16"
          next_hop_type  = "VirtualNetworkGateway"
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry # see variables.tf
}

# Create a Route Table (Primary)
resource "azurerm_virtual_hub_route_table" "example" {
  name                = "example-route-table"
  virtual_hub_id = local.vwh_id
}

# Create an additional Route Table (Propagated)
resource "azurerm_virtual_hub_route_table" "additional" {
  name                = "additional-route-table"
  virtual_hub_id = local.vwh_id
}

# Test rout map for association to connection
resource "azurerm_route_map" "in" {
  name           = "example-rm-in"
  virtual_hub_id = local.vwh_id

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
  virtual_hub_id = local.vwh_id

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