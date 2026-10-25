provider "azurerm" {
  features {}

  # subscription_id wird bewusst nicht hier gesetzt, sondern ueber die
  # Umgebungsvariable ARM_SUBSCRIPTION_ID (keine IDs im ueffentlichen Repo).
}
