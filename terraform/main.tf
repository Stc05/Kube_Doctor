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

  role_based_access_control_enabled = true

  api_server_access_profile {
    authorized_ip_ranges = [var.authorized_ip]
  }

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
  }

  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_container_registry" "main" {
  name                = "acrkubedoctorstc05"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = "kv-kubedoctor-stc05"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

resource "azurerm_role_assignment" "me_kv_secrets" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = azurerm_key_vault.main.id
}
