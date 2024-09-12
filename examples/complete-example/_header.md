# Azure ExpressRoute Circuit Module - Complete Example

This example demonstrates how to deploy an Azure ExpressRoute Circuit along with all its dependencies, including peerings (both private and Microsoft public with dual-stack IPv4/IPv6), circuit authorizations, and connections to both Virtual Network Gateway and ExpressRoute Gateway.

## This example will provision the following resources:

 - ExpressRoute Circuit: The core resource that enables private, high-bandwidth connections to Azure services.
 - Private and Public Peerings: Both private peering (for connecting on-premises resources to Azure virtual networks) and Microsoft peering (for connecting to Microsoft services such as Office 365) are configured with IPv4 and IPv6 addresses.
 - Circuit Authorizations: Grants authorization for Azure subscriptions to connect to the circuit.
 - VNet Gateway Connection: Establishes a connection between the ExpressRoute circuit and the Azure Virtual Network using a Virtual Network Gateway.
- ExpressRoute Gateway Connection: Connects the circuit to an ExpressRoute Gateway for broader network infrastructure (typically used in Virtual WAN deployments).
