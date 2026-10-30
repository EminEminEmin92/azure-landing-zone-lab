output "vnet_id" {
  description = "Azure-Ressourcen-ID des Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "IDs der Subnetze, mit dem Subnetz-Namen als Schlüssel."
  value = {
    (azurerm_subnet.this.name) = azurerm_subnet.this.id
  }
}
