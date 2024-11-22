resource "azurerm_network_interface" "nic01-lablvl1" {
  name                = var.nic
  location            = azurerm_resource_group.salomon-lablvl2.location
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-lvl1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-lvl1.id
  }
}

resource "tls_private_key" "salomon_ssh_lvl1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vmlvl1" {
  name                = var.vm1
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name
  location            = azurerm_resource_group.salomon-lablvl2.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureroot"
  network_interface_ids = [
    azurerm_network_interface.nic01-lablvl1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureroot"
    public_key = tls_private_key.salomon_ssh_lvl1.public_key_openssh
  }
}