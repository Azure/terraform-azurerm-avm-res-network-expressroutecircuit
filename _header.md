# terraform-azurerm-avm-res-network-expressroutecircuit

This is a module for deploying an Azure Express Route Circuit with it's dependencies. 
Make sure yopu check out the Azure [ExpressRoute Documentation](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction)!

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are to be expected. 
> 
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

## Resources deployed by this module
- ExpressRoute Circuit
- ExpressRoute Circuit Peering
- ExpressRoute Circuit Connection
- Resource lock
- IaM
- Diagnostic settings

## Deployment order
1. Deploy the circuit and extract the Service Key from the module output
2. Work with your service provider to enable the circuit
3. Once Circuit is in Provision State "Provisioned" yo can deploy the peering and all dependency services.

Note: If you try to deploy a peering before the circuit is in Provisioned state, the module will fail. From a Terraform perspective, we recommend to not provide any parameters for dependant resources (Peerings, Connections etc...) until after the circuit is provisioned, that way your terraform deployment will succeed and your state file will happy. 

## Known Limitations
- The number of peerings is limited to 3 for existing customers with public peering, new customers should only deploy private or Microsoft peerings according to requirements. See retirement notice for Public Peering [here](https://azure.microsoft.com/en-us/updates/retirement-notice-migrate-from-public-peering-by-march-31-2024/)
- Private link fast path is currently disabled due to known issue [#26746](https://github.com/hashicorp/terraform-provider-azurerm/issues/26746)
- When deploying a connection to your gateway, make sure to differenciate between Virtual Network Gateway and ExpressRoute Gateway. The first is deployed in Virtual Networks and the latter in Virtual WAN. From a Terraform perspectrive, they are two different resources, so we seperated them by variable definition as well to make it easy to deploy.
    - When deploying a connection to an ExpressRoute Gateway, the connection will require the Peerin ID. You can either provide the peering ID directly or you can supply the map object key you used to define the required peering in the module definition, take a look at the examples, it's a lot easier to show than to explain ;)

## Feedback
- Your feedback is welcome! Please raise an issue or feature request on the module's GitHub repository.
