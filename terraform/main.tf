resource "azurerm_resource_group" "main" {
  name     = "rg-kube-doctor"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-kube-doctor"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "kubedoctor"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}
