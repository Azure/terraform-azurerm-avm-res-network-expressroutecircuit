output "authorization_keys" {
  description = "Authorization keys for the ExpressRoute circuit."
  sensitive   = true
  value = {
    for key, value in azurerm_express_route_circuit_authorization.this : key => value.authorization_key
  }
}

output "authorization_used_status" {
  description = "Authorization used status."
  value = {
    for key, value in azurerm_express_route_circuit_authorization.this : key => value.authorization_use_status
  }
}

output "express_route_gateway_connections" {
  description = "ExpressRoute gateway connections."
  value = {
    for key, value in azurerm_express_route_connection.this : key => value
  }
}

output "name" {
  description = "The resource name of the ExpressRoute circuit."
  value       = azurerm_express_route_circuit.this.name
}

output "peerings" {
  description = "ExpressRoute Circuit peering configurations."
  value = {
    for key, value in azurerm_express_route_circuit_peering.this : key => value
  }
}

output "resource_id" {
  description = "The resource ID of the ExpressRoute circuit."
  value       = azurerm_express_route_circuit.this.id
}

output "virtual_network_gateway_connections" {
  description = "Virtual network gateway connections."
  value = {
    for key, value in azurerm_virtual_network_gateway_connection.this : key => value
  }
}
