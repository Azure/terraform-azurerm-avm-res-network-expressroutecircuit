# Module owners should include the full resource via a 'resource' output
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
