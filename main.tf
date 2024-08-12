resource "azurerm_express_route_circuit_authorization" "this" {
  for_each = var.express_route_circuit_authorizations

  express_route_circuit_name = azurerm_express_route_circuit.this.name
  name                       = each.value.name
  resource_group_name        = azurerm_express_route_circuit.this.resource_group_name
}

resource "azurerm_express_route_circuit_peering" "this" {
  for_each = var.peerings

  express_route_circuit_name    = azurerm_express_route_circuit.this.name
  peering_type                  = each.value.peering_type
  resource_group_name           = var.resource_group_name
  vlan_id                       = each.value.vlan_id
  ipv4_enabled                  = each.value.ipv4_enabled
  peer_asn                      = each.value.peer_asn
  primary_peer_address_prefix   = each.value.primary_peer_address_prefix
  route_filter_id               = each.value.route_filter_id
  secondary_peer_address_prefix = each.value.secondary_peer_address_prefix
  shared_key                    = each.value.shared_key

  dynamic "ipv6" {
    for_each = each.value.ipv6 != null ? [each.value.ipv6] : []

    content {
      primary_peer_address_prefix   = each.value.ipv6.primary_peer_address_prefix
      secondary_peer_address_prefix = each.value.ipv6.secondary_peer_address_prefix
      enabled                       = each.value.ipv6.enabled
      route_filter_id               = each.value.ipv6.route_filter_id

      dynamic "microsoft_peering" {
        for_each = each.value.ipv6.microsoft_peering != null ? [each.value.ipv6.microsoft_peering_config] : []

        content {
          advertised_communities     = each.value.ipv6.microsoft_peering.advertised_communities
          advertised_public_prefixes = each.value.ipv6.microsoft_peering.advertised_public_prefixes
          customer_asn               = each.value.ipv6.microsoft_peering.customer_asn
          routing_registry_name      = each.value.ipv6.microsoft_peering.routing_registry_name
        }
      }
    }
  }
  dynamic "microsoft_peering_config" {
    for_each = each.value.microsoft_peering_config != null ? [each.value.microsoft_peering_config] : []

    content {
      advertised_public_prefixes = each.value.microsoft_peering_config.advertised_public_prefixes
      advertised_communities     = each.value.microsoft_peering_config.advertised_communities
      customer_asn               = each.value.microsoft_peering_config.customer_asn
      routing_registry_name      = each.value.microsoft_peering_config.routing_registry_name
    }
  }
}

# Create connection between the Express Route Circuit and Virtual Network Gateways
resource "azurerm_virtual_network_gateway_connection" "this" {
  for_each = var.vnet_gw_connections

  location                     = each.value.location
  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  type                         = "ExpressRoute"
  virtual_network_gateway_id   = each.value.virtual_network_gateway_id
  authorization_key            = each.value.authorization_key
  express_route_circuit_id     = azurerm_express_route_circuit.this.id
  express_route_gateway_bypass = each.value.express_route_gateway_bypass
  routing_weight               = each.value.routing_weight
  tags                         = each.value.tags

  depends_on = [azurerm_express_route_circuit_peering.this]
}

# Create connection between the Express Route Circuit and Express Route Gateways (VWan)
resource "azurerm_express_route_connection" "this" {
  for_each = var.er_gw_connections

  express_route_circuit_peering_id     = coalesce(each.value.express_route_circuit_peering_id, try(azurerm_express_route_circuit_peering.this[each.value.peering_map_key].id, ""))
  express_route_gateway_id             = each.value.express_route_gateway_id
  name                                 = each.value.name
  express_route_gateway_bypass_enabled = false
  #private_link_fast_path_enabled = optional(bool, false) # disabled due to bug #26746
  routing_weight = each.value.routing_weight

  dynamic "routing" {
    for_each = each.value.routing != null ? [each.value.routing] : []

    content {
      associated_route_table_id = routing.value.associated_route_table_id
      inbound_route_map_id      = routing.value.inbound_route_map_id
      outbound_route_map_id     = routing.value.outbound_route_map_id

      dynamic "propagated_route_table" {
        for_each = routing.value.propagated_route_table != null ? [routing.value.propagated_route_table] : []

        content {
          labels          = propagated_route_table.value.labels
          route_table_ids = propagated_route_table.value.route_table_ids
        }
      }
    }
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_express_route_circuit.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [
    azurerm_express_route_circuit.this
  ]
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_express_route_circuit.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${var.name}"
  target_resource_id             = azurerm_express_route_circuit.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type == "Dedicated" ? null : each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups
    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}
