variable "location" {
  type        = string
  description = <<DESCRIPTION
  (Required) The location of the ExpressRoute Circuit. Changing this forces a new resource to be created.
DESCRIPTION
  nullable    = false
}

variable "name" {
  type        = string
  description = <<DESCRIPTION
  (Required) The name of the ExpressRoute Circuit. Changing this forces a new resource to be created.
DESCRIPTION
}

variable "peering_location" {
  type        = string
  description = <<DESCRIPTION
  (Required) The peering location.
DESCRIPTION
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = <<DESCRIPTION
(Required) The name of the resource group where the resources will be deployed. 
DESCRIPTION  
  nullable    = false
}

variable "service_provider_name" {
  type        = string
  description = <<DESCRIPTION
  (Required) The name of the service provider.
DESCRIPTION
  nullable    = false
}

variable "sku" {
  type = object({
    tier   = string
    family = string
  })
  description = <<DESCRIPTION
  (Required) The SKU of the ExpressRoute Circuit.
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["Local", "Standard", "Premium"], var.sku.tier)
    error_message = "The SKU tier must be either 'Local', 'Standard', or 'Premium'."
  }
  validation {
    condition     = contains(["MeteredData", "UnlimitedData"], var.sku.family)
    error_message = "The SKU family must be either 'MeteredData' or 'UnlimitedData'."
  }
}

variable "allow_classic_operations" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  (Optional) Allow classic operations.
DESCRIPTION
}

variable "authorization_key" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  (Optional) The authorization key of the ExpressRoute Circuit.
DESCRIPTION
}

variable "bandwidth_in_gbps" {
  type        = number
  default     = null
  description = <<DESCRIPTION
  (Optional) The bandwidth in Gbps.
DESCRIPTION
}

variable "bandwidth_in_mbps" {
  type        = number
  default     = null
  description = <<DESCRIPTION
  (Optional) The bandwidth in Mbps.
DESCRIPTION
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
DESCRIPTION  
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION  
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "er_gw_connections" {
  type = map(object({
    name                                      = optional(string, "")
    express_route_circuit_peering_resource_id = optional(string, null)
    peering_map_key                           = optional(string, null)
    express_route_gateway_resource_id         = string
    authorization_key                         = optional(string, null)
    enable_internet_security                  = optional(bool, false)
    express_route_gateway_bypass_enabled      = optional(bool, false)
    #private_link_fast_path_enabled = optional(bool, false) # disabled due to bug #26746
    routing_weight = optional(number, 0)
    routing = optional(object({
      associated_route_table_resource_id = optional(string)
      inbound_route_map_resource_id      = optional(string)
      outbound_route_map_resource_id     = optional(string)
      propagated_route_table = object({
        labels                   = optional(list(string), null)
        route_table_resource_ids = optional(list(string), null)
      })
    }), null)
  }))
  default     = {}
  description = <<DESCRIPTION
    (Optional) A map of association objects to create connections between the created circuit and the designated gateways. 

    - `name` - (Required) The name of the connection.
    - `express_route_circuit_peering_resource_id` - (Optional) The id of the peering to associate to. Note: Either `express_route_circuit_peering_resource_id` or `peering_map_key` must be set.
    - `peering_map_key` - (Optional) The key of the peering variable to associate to. Note: Either `peering_map_key` or `express_route_circuit_peering_resource_id` or must be set.
    - `express_route_gateway_resource_id` - (Required) Resource ID of the Express Route Gateway.
    - `authorization_key` - (Optional) The authorization key to establish the Express Route Connection.
    - `enable_internet_security` - (Optional) Set Internet security for this Express Route Connection.
    - `express_route_gateway_bypass_enabled` - (Optional) Specified whether Fast Path is enabled for Virtual Wan Firewall Hub. Defaults to false.
    - `private_link_fast_path_enabled` - [Currently disabled due to bug #26746] (Optional) Bypass the Express Route gateway when accessing private-links. When enabled express_route_gateway_bypass_enabled must be set to true. Defaults to false.
    - `routing_weight` - (Optional) The routing weight associated to the Express Route Connection. Possible value is between 0 and 32000. Defaults to 0.
    - `routing` - (Optional) A routing block.
      - `associated_route_table_resource_id` - (Optional) The ID of the Virtual Hub Route Table associated with this Express Route Connection.
      - `inbound_route_map_resource_id` - (Optional) The ID of the Route Map associated with this Express Route Connection for inbound routes.
      - `outbound_route_map_resource_id` - (Optional) The ID of the Route Map associated with this Express Route Connection for outbound routes.
      - `propagated_route_table` - (Optional) A propagated_route_table block.
        - `labels` - (Optional) The list of labels to logically group route tables.
        - `route_table_resource_ids` - (Optional) A list of IDs of the Virtual Hub Route Table to propagate routes from Express Route Connection to the route table.

    Example Input:

```terraform
    er_gw_connections = {
    connection1er = {
      name                             = "ExRConnection-westus2-er"
      express_route_gateway_resource_id         = local.same_rg_er_gw_resource_id
      express_route_circuit_peering_resource_id = local.same_rg_er_peering_resource_id
      peering_map_key = "firstPeeringConfig"
      routeting_weight = 0
      routing = {
        inbound_route_map_resource_id         = azurerm_route_map.in.id
        outbound_route_map_resource_id        = azurerm_route_map.out.id
        propagated_route_table = {
          route_table_resource_ids = [
            azurerm_virtual_hub_route_table.example.id,
            azurerm_virtual_hub_route_table.additional.id
          ]
        }
      }
    }
  }
```
  DESCRIPTION

  validation {
    condition     = alltrue([for connection in var.er_gw_connections : connection.express_route_circuit_peering_resource_id != null || connection.peering_map_key != null])
    error_message = "Either 'express_route_circuit_peering_resource_id' or 'peering_map_key' must be set for each entry in 'er_gw_connections'."
  }
  validation {
    condition     = alltrue([for connection in var.er_gw_connections : connection.routing_weight >= 0 && connection.routing_weight <= 32000])
    error_message = "routing_weight must be between 0 and 32000."
  }
}

variable "express_route_circuit_authorizations" {
  type = map(object({
    name = string
  }))
  default     = {}
  description = <<DESCRIPTION
    (Optional) A map of authorization objects to create authorizations for the ExpressRoute Circuits. 

    - `name` - (Required) The name of the authorization.

    Example Input:

```terraform
    express_route_circuit_authorizations = {
      authorization1 = {
        name              = "authorization1"
      },
      authorization2 = {
        name              = "azurerm_express_route_gateway.some_gateway.name-authorization" 
      }
    }
```
  DESCRIPTION
}

variable "express_route_port_resource_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  (Optional) The ID of the ExpressRoute Port.
DESCRIPTION
}

variable "exr_circuit_tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
  (Optional) A mapping of tags to assign to the ExpressRoute Circuit.
DESCRIPTION
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "peerings" {
  type = map(object({
    peering_type                  = string
    vlan_id                       = number
    primary_peer_address_prefix   = optional(string, null)
    secondary_peer_address_prefix = optional(string, null)
    ipv4_enabled                  = optional(bool, true)
    shared_key                    = optional(string, null)
    peer_asn                      = optional(number, null)
    route_filter_id               = optional(string, null)
    microsoft_peering_config = optional(object({
      advertised_public_prefixes = list(string)
      customer_asn               = optional(number, null)
      routing_registry_name      = optional(string, "NONE")
      advertised_communities     = optional(list(string), null)
    }), null)
    ipv6 = optional(object({
      primary_peer_address_prefix   = string
      secondary_peer_address_prefix = string
      enabled                       = optional(bool, true)
      route_filter_id               = optional(string, null)
      microsoft_peering = optional(object({
        advertised_public_prefixes = optional(list(string))
        customer_asn               = optional(number, null)
        routing_registry_name      = optional(string, "NONE")
        advertised_communities     = optional(list(string), null)
      }), null)
    }), null)
  }))
  default     = {}
  description = <<DESCRIPTION
    (Optional) A map of association objects to create peerings between the created circuit and the designated gateways. 

    - `peering_type` - (Required) The type of peering. Possible values are `AzurePrivatePeering`, `AzurePublicPeering`, and `MicrosoftPeering`.
    - `vlan_id` - (Required) The VLAN ID for the peering.
    - `primary_peer_address_prefix` - (Optional) The primary peer address prefix.
    - `secondary_peer_address_prefix` - (Optional) The secondary peer address prefix.
    - `ipv4_enabled` - (Optional) Is IPv4 enabled for this peering. Defaults to `true`.
    - `shared_key` - (Optional) The shared key for the peering.
    - `peer_asn` - (Optional) The peer ASN.
    - `route_filter_id` - (Optional) The ID of the route filter to associate with the peering.
    - `microsoft_peering_config` - (Optional) A map of Microsoft peering configuration settings.
    - `ipv6` - (Optional) A map of IPv6 peering configuration settings.

    Example Input:

```terraform
    peerings = {
      PrivatePeering = {
        peering_type                  = "AzurePrivatePeering"
        peer_asn                      = 100
        primary_peer_address_prefix   = "10.0.0.0/30"
        secondary_peer_address_prefix = "10.0.0.4/30"
        ipv4_enabled                  = true
        vlan_id                       = 300

        ipv6 {
          primary_peer_address_prefix   = "2002:db01::/126"
          secondary_peer_address_prefix = "2003:db01::/126"
          enabled                       = true
        }
      },
      MicrosoftPeering = {
        peering_type                  = "MicrosoftPeering"
        peer_asn                      = 200
        primary_peer_address_prefix   = "123.0.0.0/30"
        secondary_peer_address_prefix = "123.0.0.4/30"
        ipv4_enabled                  = true
        vlan_id                       = 400

        microsoft_peering_config {
          advertised_public_prefixes = ["123.1.0.0/24"]
        }

        ipv6 {
          primary_peer_address_prefix   = "2002:db01::/126"
          secondary_peer_address_prefix = "2003:db01::/126"
          enabled                       = true

          microsoft_peering {
            advertised_public_prefixes = ["2002:db01::/126"]
          }
        }
      }
    }
```
  DESCRIPTION

  validation {
    condition     = alltrue([for peering in var.peerings : contains(["AzurePrivatePeering", "AzurePublicPeering", "MicrosoftPeering"], peering.peering_type)])
    error_message = "The peering type must be one of: 'AzurePrivatePeering', 'AzurePublicPeering', or 'MicrosoftPeering'."
  }
  validation {
    condition     = alltrue([for peering in var.peerings : peering.vlan_id >= 0 && peering.vlan_id <= 4095])
    error_message = "The VLAN ID must be between 0 and 4095."
  }
  validation {
    condition = alltrue([for peering in var.peerings :
      can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/30$", peering.primary_peer_address_prefix)) &&
      can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/30$", peering.secondary_peer_address_prefix))
    ])
    error_message = "The primary and secondary peer address prefix must be in the form of an IP address CIDR notation with a subnet size of 30 bit mask."
  }
  validation {
    condition     = length([for peering in var.peerings : peering.peering_type]) <= 3
    error_message = "The number of peerings can be up to 3."
  }
  validation {
    condition     = length([for peering in var.peerings : peering.peering_type]) == length(distinct([for peering in var.peerings : peering.peering_type]))
    error_message = "One peering of each type is allowed."
  }
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "vnet_gw_connections" {
  type = map(object({
    name                                = optional(string, "")
    resource_group_name                 = string
    location                            = string
    virtual_network_gateway_resource_id = string
    authorization_key                   = optional(string, null)
    routing_weight                      = optional(number, 0)
    express_route_gateway_bypass        = optional(bool, false)
    #private_link_fast_path_enabled = optional(bool, false) # disabled due to bug #26746 
    shared_key = optional(string, null)
    tags       = optional(map(string), null)
  }))
  default     = {}
  description = <<DESCRIPTION
    (Optional) A map of association objects to create connections between the created circuit and the designated gateways. 

    - `name` - (Required) The name of the connection.
    - `resource_group_name` - (Required) The name of the resource group in which to create the connection Changing this forces a new resource to be created.
    - `location` - (Required) The location/region where the connection is located. 
    - `virtual_network_gateway_resource_id` - (Required) The ID of the Virtual Network Gateway in which the connection will be created.
    - `authorization_key` - (Optional) The authorization key associated with the Express Route Circuit.
    - `routing_weight` - (Optional) The routing weight. Defaults to 0.
    - `express_route_gateway_bypass` - (Optional) If true, data packets will bypass ExpressRoute Gateway for data forwarding.
    - `private_link_fast_path_enabled` - [Currently disabled due to bug #26746] (Optional) Bypass the Express Route gateway when accessing private-links. When enabled express_route_gateway_bypass must be set to true. Defaults to false.
    - `tags` - (Optional) A mapping of tags to assign to the resource.

    Example Input:

```terraform
  vnet_gw_connections = {
    connection1gw = {
      name                       = local.same_rg_conn_name
      virtual_network_gateway_resource_id = local.same_rg_gw_resource_id
      location                   = local.location
      resource_group_name        = local.resource_group_name
    }
  }
```
  DESCRIPTION

  validation {
    condition     = alltrue([for connection in var.vnet_gw_connections : can(regex("^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[a-zA-Z0-9._-]+/providers/Microsoft.Network/virtualNetworkGateways/[a-zA-Z0-9._-]+$", connection.virtual_network_gateway_resource_id))])
    error_message = "virtual_network_gateway_resource_id must be in the form of an Azure resource ID."
  }
  validation {
    condition     = alltrue([for connection in var.vnet_gw_connections : connection.routing_weight >= 0 && connection.routing_weight <= 32000])
    error_message = "routing_weight must be between 0 and 32000."
  }
}
