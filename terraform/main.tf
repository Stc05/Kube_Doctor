resource "azurerm_resource_group" "main" {
  name     = "rg-kube-doctor"
  location = var.location
}
