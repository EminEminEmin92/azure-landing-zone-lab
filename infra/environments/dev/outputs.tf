output "resource_group_name" {
  description = "Name der Resource Group dieser Umgebung."
  value       = azurerm_resource_group.lab.name
}
