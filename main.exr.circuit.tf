
# Create the Express Route Circuit
resource "azurerm_express_route_circuit" "this" {
  location                 = data.azurerm_resource_group.parent.location
  name                     = var.exr_circuit_name
  resource_group_name      = var.resource_group_name
  allow_classic_operations = var.allow_classic_operations
  authorization_key        = var.authorization_key
  bandwidth_in_gbps        = var.bandwidth_in_gbps
  bandwidth_in_mbps        = var.bandwidth_in_mbps
  express_route_port_id    = var.express_route_port_id
  peering_location         = var.peering_location
  service_provider_name    = var.service_provider_name
  tags                     = local.exr_circuit_tags

  sku {
    family = var.sku.family
    tier   = var.sku.tier
  }
}
