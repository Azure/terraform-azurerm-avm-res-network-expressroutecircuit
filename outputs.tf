# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "expressroute_circuit" {
  description = "Express Route Circuit resource."
  value       = azurerm_express_route_circuit.this
}
