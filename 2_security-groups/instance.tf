resource "azurerm_virtual_machine" "azure-instance1" {
  name                  = "${var.prefix}-vm1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.azure.name
  network_interface_ids = [azurerm_network_interface.azure-instance1.id]
  vm_size               = "Standard_A1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  # az vm image list -p "Canonical" --all
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk1"
    caching           = "ReadWrite" # None, ReadOnly, ReadWrite
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS" # Standard_LRS, StandardSSD_LRS, Premium_LRS, UltraSSD_LRS
  }

  os_profile {
    computer_name_prefix = "${var.prefix}-instance"
    admin_username       = "erdem"
    #admin_password = "..."
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("/home/erdem/.ssh/id_rsa.pub")
      path     = "/home/erdem/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_network_interface" "azure-instance1" {
  name                = "${var.prefix}-instance1"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure.name

  ip_configuration {
    name                          = "instance1"
    subnet_id                     = azurerm_subnet.azure-internal1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure-instance1.id
  }
}

resource "azurerm_public_ip" "azure-instance1" {
  name                = "${var.prefix}-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface_security_group_association" "azure-instance1" {
  network_interface_id      = azurerm_network_interface.azure-instance1.id
  network_security_group_id = azurerm_network_security_group.allow-ssh.id
}

resource "azurerm_application_security_group" "azure-instance-group" {
  name                = "internet-facing"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure.name
}

resource "azurerm_network_interface_application_security_group_association" "azure-instance-group" {
  network_interface_id          = azurerm_network_interface.azure-instance1.id
  application_security_group_id = azurerm_application_security_group.azure-instance-group.id
}


# demo instance 2
resource "azurerm_virtual_machine" "azure-instance2" {
  name                  = "${var.prefix}-vm2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.azure.name
  network_interface_ids = [azurerm_network_interface.azure-instance2.id]
  vm_size               = "Standard_A1_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  # az vm image list -p "Canonical" --all
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk2"
    caching           = "ReadWrite" # None, ReadOnly, ReadWrite
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS" # Standard_LRS, StandardSSD_LRS, Premium_LRS, UltraSSD_LRS
  }

  os_profile {
    computer_name  = "azure-instance"
    admin_username = "erdem"
    #admin_password = "..."
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("/home/erdem/.ssh/id_rsa.pub")
      path     = "/home/erdem/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_network_interface" "azure-instance2" {
  name                = "${var.prefix}-instance2"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure.name

  ip_configuration {
    name                          = "instance2"
    subnet_id                     = azurerm_subnet.azure-internal1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "azure-instance2" {
  network_interface_id      = azurerm_network_interface.azure-instance2.id
  network_security_group_id = azurerm_network_security_group.internal-facing.id
}