<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-network-expressroutecircuit

This is a module for deploying an Azure Express Route Circuit with it's dependencies.
Make sure you check out the Azure [ExpressRoute Documentation](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction)!

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are to be expected.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

## Resources deployed by this module
- ExpressRoute Circuit
- ExpressRoute Circuit Private Peering
- ExpressRoute Circuit Microsoft Peering
- ExpressRoute Circuit Connection
- Resource lock
- IaM
- Diagnostic settings

## Deployment order
1. Deploy ExpressRoute Circuit 
1. Extract Service Key from the module output
1. [Work with your service provider to enable the circuit](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-howto-circuit-portal-resource-manager#send-the-service-key-to-your-connectivity-provider-for-provisioning)
1. Once Circuit is in "Provisioned" state, you can deploy the peering (private and Microsoft) and all dependency services.

Note: If you try to deploy a peering before the circuit is in Provisioned state, the module will fail. From a Terraform perspective, we recommend to not provide any parameters for dependant resources (Peerings, Connections etc...) until after the circuit is provisioned, that way your terraform deployment will succeed and your state file will happy.

## Known Limitations
- The number of peerings is limited to 3 for existing customers with public peering, new customers should only deploy private or Microsoft peerings according to requirements. See retirement notice for Public Peering [here](https://azure.microsoft.com/en-us/updates/retirement-notice-migrate-from-public-peering-by-march-31-2024/)
- Private link fast path is currently disabled due to known issue [#26746](https://github.com/hashicorp/terraform-provider-azurerm/issues/26746)
- When deploying a connection to your gateway, make sure to differenciate between Virtual Network Gateway and ExpressRoute Gateway. The first is deployed in Virtual Networks and the latter in Virtual WAN. From a Terraform perspectrive, they are two different resources, so we seperated them by variable definition as well to make it easy to deploy.
    - When deploying a connection to an ExpressRoute Gateway, the connection will require the Peerin ID. You can either provide the peering ID directly or you can supply the map object key you used to define the required peering in the module definition, take a look at the examples, it's a lot easier to show than to explain ;)

## Feedback
- Your feedback is welcome! Please raise an issue or feature request on the module's GitHub repository.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (> 3.71, <= 3.99.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (> 3.71, <= 3.99.0)

- <a name="provider_modtm"></a> [modtm](#provider\_modtm) (~> 0.3)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_express_route_circuit.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit) (resource)
- [azurerm_express_route_circuit_authorization.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_authorization) (resource)
- [azurerm_express_route_circuit_peering.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) (resource)
- [azurerm_express_route_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_connection) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_virtual_network_gateway_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description:   (Required) The location of the ExpressRoute Circuit. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description:   (Required) The name of the ExpressRoute Circuit. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_peering_location"></a> [peering\_location](#input\_peering\_location)

Description:   (Required) The peering location.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: (Required) The name of the resource group where the resources will be deployed.

Type: `string`

### <a name="input_service_provider_name"></a> [service\_provider\_name](#input\_service\_provider\_name)

Description:   (Required) The name of the service provider.

Type: `string`

### <a name="input_sku"></a> [sku](#input\_sku)

Description:   (Required) The SKU of the ExpressRoute Circuit.

Type:

```hcl
object({
    tier   = string
    family = string
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_allow_classic_operations"></a> [allow\_classic\_operations](#input\_allow\_classic\_operations)

Description:   (Optional) Allow classic operations.

Type: `bool`

Default: `false`

### <a name="input_authorization_key"></a> [authorization\_key](#input\_authorization\_key)

Description:   (Optional) The authorization key of the ExpressRoute Circuit.

Type: `string`

Default: `null`

### <a name="input_bandwidth_in_gbps"></a> [bandwidth\_in\_gbps](#input\_bandwidth\_in\_gbps)

Description:   (Optional) The bandwidth in Gbps.

Type: `number`

Default: `null`

### <a name="input_bandwidth_in_mbps"></a> [bandwidth\_in\_mbps](#input\_bandwidth\_in\_mbps)

Description:   (Optional) The bandwidth in Mbps.

Type: `number`

Default: `null`

### <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key)

Description: A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.

Type:

```hcl
object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
```

Default: `null`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_er_gw_connections"></a> [er\_gw\_connections](#input\_er\_gw\_connections)

Description:     (Optional) A map of association objects to create connections between the created circuit and the designated gateways.

    - `name` - (Required) The name of the connection.
    - `express_route_circuit_peering_id` - (Optional) The id of the peering to associate to. Note: Either `express_route_circuit_peering_id` or `peering_map_key` must be set.
    - `peering_map_key` - (Optional) The key of the peering variable to associate to. Note: Either `peering_map_key` or `express_route_circuit_peering_id` or must be set.
    - `express_route_gateway_id` - (Required) Resource ID of the Express Route Gateway.
    - `authorization_key` - (Optional) The authorization key to establish the Express Route Connection.
    - `enable_internet_security` - (Optional) Set Internet security for this Express Route Connection.
    - `express_route_gateway_bypass_enabled` - (Optional) Specified whether Fast Path is enabled for Virtual Wan Firewall Hub. Defaults to false.
    - `private_link_fast_path_enabled` - [Currently disabled due to bug #26746] (Optional) Bypass the Express Route gateway when accessing private-links. When enabled express\_route\_gateway\_bypass\_enabled must be set to true. Defaults to false.
    - `routing_weight` - (Optional) The routing weight associated to the Express Route Connection. Possible value is between 0 and 32000. Defaults to 0.
    - `routing` - (Optional) A routing block.
      - `associated_route_table_id` - (Optional) The ID of the Virtual Hub Route Table associated with this Express Route Connection.
      - `inbound_route_map_id` - (Optional) The ID of the Route Map associated with this Express Route Connection for inbound routes.
      - `outbound_route_map_id` - (Optional) The ID of the Route Map associated with this Express Route Connection for outbound routes.
      - `propagated_route_table` - (Optional) A propagated\_route\_table block.
        - `labels` - (Optional) The list of labels to logically group route tables.
        - `route_table_ids` - (Optional) A list of IDs of the Virtual Hub Route Table to propagate routes from Express Route Connection to the route table.

    Example Input:

```terraform
    er_gw_connections = {
    connection1er = {
      name                             = "ExRConnection-westus2-er"
      express_route_gateway_id         = local.same_rg_er_gw_id
      express_route_circuit_peering_id = local.same_rg_er_peering_id
      peering_map_key = "firstPeeringConfig"
      routeting_weight = 0
      routing = {
        inbound_route_map_id         = azurerm_route_map.in.id
        outbound_route_map_id        = azurerm_route_map.out.id
        propagated_route_table = {
          route_table_ids = [
            azurerm_virtual_hub_route_table.example.id,
            azurerm_virtual_hub_route_table.additional.id
          ]
        }
      }
    }
  }
```

Type:

```hcl
map(object({
    name                                 = string
    express_route_circuit_peering_id     = optional(string, null)
    peering_map_key                      = optional(string, null)
    express_route_gateway_id             = string
    authorization_key                    = optional(string, null)
    enable_internet_security             = optional(bool, false)
    express_route_gateway_bypass_enabled = optional(bool, false)
    #private_link_fast_path_enabled = optional(bool, false) # disabled due to bug #26746
    routing_weight = optional(number, 0)
    routing = optional(object({
      associated_route_table_id = optional(string)
      inbound_route_map_id      = optional(string)
      outbound_route_map_id     = optional(string)
      propagated_route_table = object({
        labels          = optional(list(string), null)
        route_table_ids = optional(list(string), null)
      })
    }), null)
  }))
```

Default: `{}`

### <a name="input_express_route_circuit_authorizations"></a> [express\_route\_circuit\_authorizations](#input\_express\_route\_circuit\_authorizations)

Description:     (Optional) A map of authorization objects to create authorizations for the ExpressRoute Circuits.

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

Type:

```hcl
map(object({
    name = string
  }))
```

Default: `{}`

### <a name="input_express_route_port_id"></a> [express\_route\_port\_id](#input\_express\_route\_port\_id)

Description:   (Optional) The ID of the ExpressRoute Port.

Type: `string`

Default: `null`

### <a name="input_exr_circuit_tags"></a> [exr\_circuit\_tags](#input\_exr\_circuit\_tags)

Description:   (Optional) A mapping of tags to assign to the ExpressRoute Circuit.

Type: `map(string)`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_peerings"></a> [peerings](#input\_peerings)

Description:     (Optional) A map of association objects to create peerings between the created circuit and the designated gateways.

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

Type:

```hcl
map(object({
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
```

Default: `{}`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_vnet_gw_connections"></a> [vnet\_gw\_connections](#input\_vnet\_gw\_connections)

Description:     (Optional) A map of association objects to create connections between the created circuit and the designated gateways.

    - `name` - (Required) The name of the connection.
    - `resource_group_name` - (Required) The name of the resource group in which to create the connection Changing this forces a new resource to be created.
    - `location` - (Required) The location/region where the connection is located.
    - `virtual_network_gateway_id` - (Required) The ID of the Virtual Network Gateway in which the connection will be created.
    - `authorization_key` - (Optional) The authorization key associated with the Express Route Circuit.
    - `routing_weight` - (Optional) The routing weight. Defaults to 0.
    - `express_route_gateway_bypass` - (Optional) If true, data packets will bypass ExpressRoute Gateway for data forwarding.
    - `private_link_fast_path_enabled` - [Currently disabled due to bug #26746] (Optional) Bypass the Express Route gateway when accessing private-links. When enabled express\_route\_gateway\_bypass must be set to true. Defaults to false.
    - `tags` - (Optional) A mapping of tags to assign to the resource.

    Example Input:

```terraform
  vnet_gw_connections = {
    connection1gw = {
      name                       = local.same_rg_conn_name
      virtual_network_gateway_id = local.same_rg_gw_id
      location                   = local.location
      resource_group_name        = local.resource_group_name
    }
  }
```

Type:

```hcl
map(object({
    name                         = string
    resource_group_name          = string
    location                     = string
    virtual_network_gateway_id   = string
    authorization_key            = optional(string, null)
    routing_weight               = optional(number, 0)
    express_route_gateway_bypass = optional(bool, false)
    #private_link_fast_path_enabled = optional(bool, false) # disabled due to bug #26746
    shared_key = optional(string, null)
    tags       = optional(map(string), null)
  }))
```

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_authorisation_keys"></a> [authorisation\_keys](#output\_authorisation\_keys)

Description: Authorisation keys for the ExpressRoute circuit.

### <a name="output_authorisation_used_status"></a> [authorisation\_used\_status](#output\_authorisation\_used\_status)

Description: Authorisation used status.

### <a name="output_express_route_gateway_connections"></a> [express\_route\_gateway\_connections](#output\_express\_route\_gateway\_connections)

Description: ExpressRoute gateway connections.

### <a name="output_name"></a> [name](#output\_name)

Description: The resource name of the ExpressRoute circuit.

### <a name="output_peerings"></a> [peerings](#output\_peerings)

Description: ExpressRoute Circuit peering configurations.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The Azure ExpressRoute circuit resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource ID of the ExpressRoute circuit.

### <a name="output_virtual_network_gateway_connections"></a> [virtual\_network\_gateway\_connections](#output\_virtual\_network\_gateway\_connections)

Description: Virtual network gateway connections.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->
