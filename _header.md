## Azure ExpressRoute Circuit Deployment Module

This module helps you deploy an Azure ExpressRoute Circuit and its related dependencies. Before using this module, be sure to review the official Azure [ExpressRoute Documentation](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction).

> [!IMPORTANT]
> As the overall AVM (Azure Virtual Machine) framework is not yet GA (Generally Available), the CI (Continuous Integration) framework and test automation may not be fully functional across all supported languages. **Breaking changes** are possible. 
> 
> However, this **DOES NOT** imply that the modules are unusable. These modules **CAN** be used in all environments—whether dev, test, or production. Treat them as you would any other Infrastructure-as-Code (IaC) module, and feel free to raise issues or request features as you use the module. Be sure to check the release notes before updating to newer versions to review any breaking changes or considerations.

## Resources Deployed by this Module
- ExpressRoute Circuit
- ExpressRoute Circuit Peering
- ExpressRoute Circuit Connection
- Resource Lock
- IAM (Identity and Access Management)
- Diagnostic Settings

## Deployment Process

1. **Deploy the ExpressRoute Circuit**: Start by deploying the circuit. After deployment, extract the Service Key from the module's output.
   
2. **Work with Your Service Provider**: Share the Service Key with your service provider to activate the circuit.

3. **Deploy Peering and Dependencies**: Once the circuit status is **Provisioned**, deploy the peering, connections and any related services.

> **Note**: If you attempt to deploy peering before the circuit is in the **Provisioned** state, the module deployment will fail. In Terraform, it’s recommended **not** to pass parameters for dependent resources (such as Peerings or Connections) until after the circuit is provisioned. This ensures a successful Terraform deployment and a stable state file.

## Important Notes

- **Peering Limit**: The number of peerings is limited to three for existing customers using public peering. New ER deployments should only deploy private or Microsoft peerings. Refer to the [retirement notice for Public Peering](https://azure.microsoft.com/en-us/updates/retirement-notice-migrate-from-public-peering-by-march-31-2024/).

- **Gateway Connection Clarification**: When deploying a connection, ensure that you distinguish between a **Virtual Network Gateway** and an **ExpressRoute Gateway**. The former is deployed in Virtual Networks, while the latter is used in Virtual WANs. In Terraform, they are represented as two different resource types, and we've separated them by variable definition for ease of deployment.
   
   - For connections to an ExpressRoute Gateway, you will need the Peering ID. You can either provide the Peering ID directly or use the key from the map object you defined in the module for the required peering. Refer to the examples in the module for more clarity, as it's easier to understand through the examples.

## Feedback
We welcome your feedback! If you encounter any issues or have feature requests, please raise them in the module’s GitHub repository.

---
