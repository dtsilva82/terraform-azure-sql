data "azurerm_resource_group" "data" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "data" {
  name                = var.storage_accounta_name
  resource_group_name = var.resource_group_name

  depends_on = [
    data.azurerm_resource_group.data
  ]
}

data "azurerm_storage_container" "data" {
  name                 = var.container_name
  storage_account_name = data.azurerm_storage_account.data.name

  depends_on = [
    data.azurerm_storage_account.data
  ]
}