
# Create the Express Route Circuit
resource "azurerm_express_route_circuit" "this" {
  name                  = var.exr_circuit_name
  resource_group_name   = var.resource_group_name
  location              = data.azurerm_resource_group.parent.location
  service_provider_name = var.service_provider_name
  peering_location      = var.peering_location
  bandwidth_in_mbps     = var.bandwidth_in_mbps
  bandwidth_in_gbps     = var.bandwidth_in_gbps
  sku {
    tier   = var.sku.tier
    family = var.sku.family
  }
  allow_classic_operations = var.allow_classic_operations
  express_route_port_id = var.express_route_port_id
  authorization_key = var.authorization_key
  
  tags = local.exr_circuit_tags
}
