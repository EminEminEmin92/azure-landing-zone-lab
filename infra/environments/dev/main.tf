locals {
  # Pflicht-Tags für alle Ressourcen dieser Umgebung
  tags = {
    workload    = var.workload
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "../../modules/network"

  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  tags                = local.tags

  vnet_name             = "vnet-${var.workload}-${var.environment}"
  vnet_address_space    = "10.10.0.0/16"
  subnet_name           = "snet-workload"
  subnet_address_prefix = "10.10.1.0/24"
  nsg_name              = "nsg-workload-${var.environment}"
}
