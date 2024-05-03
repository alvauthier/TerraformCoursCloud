variable "resource_group" {
  type    = string
  default = "TerraformMiniProject"
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "username" {
  type    = string
  default = "username"
}

variable "password" {
  type    = string
  default = "password"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.101.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_main" {
  name     = var.resource_group
  location = var.location
  tags = {
    environment = "Terraform Mini Project"
  }
}

resource "azurerm_virtual_network" "avn_main" {
  name                = "TerraformMiniProject-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_main.name
}

resource "azurerm_subnet" "asub_main" {
  name                 = "internal"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.avn_main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "apip_main" {
  name                = "TerraformMiniProject-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_main.name
  sku                 = "Standard"
  allocation_method   = "Static"

  provisioner "local-exec" {
    command = "echo DOMAIN_NAME=${self.ip_address} >> back.env"
  }
  provisioner "local-exec" {
    command = "echo URL=http://${self.ip_address} >> back.env"
  }
  provisioner "local-exec" {
    command = "echo URL_SITE_CLIENT=http://${self.ip_address}:3000 >> back.env"
  }

  provisioner "local-exec" {
    command = "echo VITE_URL=http://${self.ip_address} >> front.env"
  }

  provisioner "local-exec" {
    command = "echo VITE_DOMAIN_NAME=${self.ip_address} >> front.env"
  }

  provisioner "local-exec" {
    command = "echo VITE_URL_SITE_CLIENT=http://${self.ip_address}:3000 >> front.env"
  }
}

resource "azurerm_network_security_group" "ansg_main" {
  name                = "TerraformMiniProject-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_main.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_main.name
  network_security_group_name = azurerm_network_security_group.ansg_main.name
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_main.name
  network_security_group_name = azurerm_network_security_group.ansg_main.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "HTTP"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_main.name
  network_security_group_name = azurerm_network_security_group.ansg_main.name
}

resource "azurerm_network_security_rule" "backend" {
  name                        = "Backend"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_main.name
  network_security_group_name = azurerm_network_security_group.ansg_main.name
}

resource "azurerm_network_interface" "anic_main" {
  name                = "TerraformMiniProject-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.asub_main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.apip_main.id
  }
}

resource "azurerm_network_interface_security_group_association" "anicnsg_assoc_main" {
  network_interface_id      = azurerm_network_interface.anic_main.id
  network_security_group_id = azurerm_network_security_group.ansg_main.id
}

resource "azurerm_linux_virtual_machine" "alinuxvm_main" {
  name                            = "TerraformMiniProject-machine"
  resource_group_name             = azurerm_resource_group.rg_main.name
  location                        = var.location
  size                            = "Standard_B2s"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.anic_main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

resource "null_resource" "installscript" {
  depends_on = [azurerm_public_ip.apip_main, azurerm_linux_virtual_machine.alinuxvm_main]
  connection {
    type     = "ssh"
    user     = var.username
    password = var.password
    host     = azurerm_public_ip.apip_main.ip_address
  }

  provisioner "file" {
    source      = "./script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = "./back.env"
    destination = "/tmp/back.env"
  }

  provisioner "file" {
    source      = "./front.env"
    destination = "/tmp/front.env"
  }

  provisioner "file" {
    source      = "./default"
    destination = "/tmp/default"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo mv /tmp/back.env ./",
      "sudo mv /tmp/front.env ./",
      "sudo mv /tmp/script.sh ./",
      "sudo mv /tmp/default ./",
      "sudo chmod 777 ./script.sh",
      "sudo chmod 777 ./default",
      "sudo chmod 777 ./back.env",
      "sudo chmod 777 ./front.env",
      "./script.sh ${var.username}",
    ]
  }

}

output "public_ip" {
  value = azurerm_public_ip.apip_main.ip_address
}
