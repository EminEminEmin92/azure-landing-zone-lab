output "resource_group_name" {
  description = "Name der Resource Group dieser Umgebung."
  value       = azurerm_resource_group.lab.name
}

output "vnet_id" {
  description = "ID des Virtual Network aus dem Netzwerk-Modul. Enthaelt die Subscription-ID, deshalb sensitive."
  value       = module.network.vnet_id
  sensitive   = true
}

output "subnet_ids" {
  description = "IDs der Subnetze aus dem Netzwerk-Modul, mit dem Subnetz-Namen als Schluessel. Enthaelt die Subscription-ID, deshalb sensitive."
  value       = module.network.subnet_ids
  sensitive   = true
}
