resource "azurerm_virtual_network" "vnet-lablvl1" {
  name                = var.vnet
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.salomon-lablvl2.location
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name
}

resource "azurerm_subnet" "snet-lvl1" {
  name                 = var.snet
  resource_group_name  = azurerm_resource_group.salomon-lablvl2.name
  virtual_network_name = azurerm_virtual_network.vnet-lablvl1.name
  address_prefixes     = ["10.100.1.0/24"]
}

resource "azurerm_public_ip" "pip-lvl1" {
  name                = var.pip
  location            = azurerm_resource_group.salomon-lablvl2.location
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name
  allocation_method   = "Dynamic"
}