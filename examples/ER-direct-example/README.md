<!-- BEGIN_TF_DOCS -->
# Azure ExpressRoute Circuit Module - with Express Route Direct

This example demonstrates how to deploy an Azure ExpressRoute Circuit using the module over a ExpressRoute Direct port.

## This example will:
 - Deploy an ExpressRoute Direct port
 - Deploy an ExpressRoute Circuit connected to the port.

```hcl
terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "none"
}

locals {
  bandwidth_in_gbps = 10
  encapsulation     = "Dot1Q"
  erd_port_name     = "office1"
  family            = "MeteredData"
  peering_location  = "Equinix-Amsterdam-AM5"
  tier              = "Premium"
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "avm_utl_regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.avm_utl_regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.avm_utl_regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

resource "azurerm_express_route_port" "example" {
  bandwidth_in_gbps   = local.bandwidth_in_gbps
  encapsulation       = local.encapsulation
  location            = azurerm_resource_group.this.location
  name                = "erd-${local.erd_port_name}"
  peering_location    = local.peering_location
  resource_group_name = azurerm_resource_group.this.name

  link1 {
    admin_enabled = false
    macsec_cipher = "GcmAes256"
  }
  link2 {
    admin_enabled = false
    macsec_cipher = "GcmAes256"
  }
}

# This is the module call
module "exr_circuit_test" {
  source = "../../"

  location            = azurerm_resource_group.this.location
  name                = module.naming.express_route_circuit.name_unique
  resource_group_name = azurerm_resource_group.this.name
  sku = {
    tier   = local.tier
    family = local.family
  }
  bandwidth_in_gbps              = 10
  enable_telemetry               = var.enable_telemetry # see variables.tf
  express_route_port_resource_id = azurerm_express_route_port.example.id
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_express_route_port.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_port) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm_utl_regions"></a> [avm\_utl\_regions](#module\_avm\_utl\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: ~> 0.3.0

### <a name="module_exr_circuit_test"></a> [exr\_circuit\_test](#module\_exr\_circuit\_test)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->