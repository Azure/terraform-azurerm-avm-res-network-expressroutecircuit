
variable "location" {
  type        = string
  description = <<DESCRIPTION
  (Required) The location of the ExpressRoute Circuit. Changing this forces a new resource to be created.
DESCRIPTION
  nullable    = false
}

# variable "name" { - TODO - add name variable, might already be in here
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

variable "connections" {
  type = map(object({
    connection_name                      = string
    gateway_resource_id                  = string
    express_route_circuit_peering_id     = string
    authorization_key                    = optional(string, null)
    enable_internet_security             = optional(bool, false)
    express_route_gateway_bypass_enabled = optional(bool, false)
    private_link_fast_path_enabled       = optional(bool, false)
    routing_weight                       = optional(number, 0)
    routing = optional(object({
      associated_route_table_id = string
      inbound_route_map_id      = string
      outbound_route_map_id     = string
      propagated_route_table = object({
        labels          = list(string)
        route_table_ids = list(string)
      })
    }), null)
  }))
  default     = {}
  description = <<DESCRIPTION
    (Optional) A map of association objects to create connections between the created circuit and the designated gateways. 

    - `connection_name` - (Required) The name of the connection.
    - `gateway_resource_id` - (Required) The id of the gateway resource, must be supplied in the form of an Azure resource ID.

    Example Input:

    ```terraform
    connections = {
      connection1 = {
        connection_name     = var.connection1-name
        gateway_resource_id = azurerm_express_route_gateway.example.id
      },
      connection2 = {
        connection_name     = "connection2"
        gateway_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.Network/expressRouteGateways/myExpressRouteGateway"
      }
    }
    ```
  DESCRIPTION

  validation {
    condition     = alltrue([for connection in var.connections : can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/[^/]+/[^/]+$", connection.gateway_resource_id))])
    error_message = "If next_hop_type is not VirtualAppliance, next_hop_in_ip_address must be null."
  }
  validation {
    condition     = alltrue([for connection in var.connections : connection.weight >= 0 && connection.weight <= 32000])
    error_message = "If next_hop_type is not VirtualAppliance, next_hop_in_ip_address must be null."
  }
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
  (Required) The name of the ExpressRoute Circuit. Changing this forces a new resource to be created.
DESCRIPTION
  nullable    = false
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

variable "express_route_port_id" {
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
    peering_type = string
    # express_route_circuit_name  = string
    # resource_group_name         = string
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
      microsoft_peering_config = optional(object({
        advertised_public_prefixes = list(string)
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
