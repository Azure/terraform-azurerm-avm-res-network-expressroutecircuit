<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.71)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_express_route_circuit.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit) (resource)
- [azurerm_express_route_circuit_peering.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_resource_group.parent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

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

### <a name="input_telemetry_resource_group_name"></a> [telemetry\_resource\_group\_name](#input\_telemetry\_resource\_group\_name)

Description: The resource group where the telemetry will be deployed.

Type: `string`

Default: `""`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The resource name of the ExpressRoute circuit.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The Azure ExpressRoute circuit resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource ID of the ExpressRoute circuit.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->