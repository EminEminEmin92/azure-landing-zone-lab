terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Partial Configuration: Die Werte (Storage Account, Container, Key) kommen
  # beim init aus der lokalen backend.hcl, die nicht ins Repo gehoert.
  backend "azurerm" {}
}
