# main.tf
# Définition de l'infrastructure Azure pour le TP1

# Le provider est défini dans provider.tf

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Crée un Virtual Network (VNet) Azure
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Crée un subnet dans le VNet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

# Crée un Network Security Group (NSG) pour le subnet
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Autorise les connexions entrantes sur le port 80 (HTTP)
  security_rule {
    name                       = "AllowAppPort"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.app_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Autorise les connexions entrantes sur le port 22 (SSH)
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Autorise les connexions entrantes sur le port 27017 (MongoDB)
  security_rule {
    name                       = "AllowMongoDBPort"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27017"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associe le NSG au subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Crée une IP publique pour le Load Balancer
resource "azurerm_public_ip" "lb_pip" {
  name                = "lb-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Crée un Load Balancer
resource "azurerm_lb" "lb" {
  name                = "app-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  # Crée une configuration d'IP publique pour le Load Balancer
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

# Crée un backend pool pour le Load Balancer
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackendPool"
}

# Crée une règle de Load Balancer pour l'application
resource "azurerm_lb_rule" "app_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "AppRule"
  protocol                       = "Tcp"
  frontend_port                  = var.app_port
  backend_port                   = var.app_port
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
}

# Crée des interfaces réseau pour les VMs applicatives
resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "nic-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Crée une configuration d'IP pour l'interface réseau
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # Pas d'IP publique directe, les VMs seront accessibles via le Load Balancer
  }
}

# Associe les interfaces réseau au backend pool du Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_association" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

# Crée des VMs applicatives
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = 2
  name                  = "vm-${count.index + 1}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key_content
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# Crée une IP publique pour MongoDB
resource "azurerm_public_ip" "mongodb_pip" {
  name                = "mongodb-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Crée une interface réseau pour MongoDB
resource "azurerm_network_interface" "mongodb_nic" {
  name                = "mongodb-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Crée une configuration d'IP pour l'interface réseau
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mongodb_pip.id
  }
}

# Crée une VM pour MongoDB
resource "azurerm_linux_virtual_machine" "mongodb" {
  name                  = "mongodb-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.mongodb_nic.id]
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key_content
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
