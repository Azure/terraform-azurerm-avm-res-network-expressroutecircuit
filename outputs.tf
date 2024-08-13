# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "name" {
  description = "The resource name of the ExpressRoute circuit."
  value       = azurerm_express_route_circuit.this.name
}

output "resource" {
  description = "The Azure ExpressRoute circuit resource."
  value       = azurerm_express_route_circuit.this
}

output "resource_id" {
  description = "The resource ID of the ExpressRoute circuit."
  value       = azurerm_express_route_circuit.this.id
}

output "authorisation_keys" {
  description = "Authorisation keys for the ExpressRoute circuit."
  value = {
    for key, value in azurerm_express_route_circuit_authorization.this : key => value.authorization_key
  }
  sensitive = true
}

output "authorisation_used_status" {
  description = "Authorisation used status."
  value = {
    for key, value in azurerm_express_route_circuit_authorization.this : key => value.authorization_use_status
  }
}

output "peerings" {
  description = "ExpressRoute Circuit peering configurations."
  value = {
    for key, value in azurerm_express_route_circuit_peering.this : key => value
  }
}

output "virtual_network_gateway_connections" {
  description = "Virtual network gateway connections."
  value = {
    for key, value in azurerm_virtual_network_gateway_connection.this : key => value
  }
}

output "express_route_gateway_connections" {
  description = "ExpressRoute gateway connections."
  value = {
    for key, value in azurerm_express_route_connection.this : key => value
  }
}