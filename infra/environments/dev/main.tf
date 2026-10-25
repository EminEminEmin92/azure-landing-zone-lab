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
