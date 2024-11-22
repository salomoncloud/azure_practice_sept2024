resource "azurerm_storage_account" "tflablvl1" {
  name                     = "tflablvl1"
  resource_group_name      = azurerm_resource_group.salomon-lablvl2.name
  location                 = azurerm_resource_group.salomon-lablvl2.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "terraform"
  }
}

resource "azurerm_storage_container" "tflablvl1state" {
  name                  = "tflablvl1state"
  storage_account_name  = azurerm_storage_account.tflablvl1.name
  container_access_type = "private"
}