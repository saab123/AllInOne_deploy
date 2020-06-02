

# resource "azurerm_resource_group" "main" {
#   name     = "RG-Lab-Internship-2020"
#   location = "westeurope"
# }




resource "azurerm_network_security_group" "master" {
  name                = "ResourceGroupmaster"
  location            = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"

  security_rule {
    name                       = "ssh-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "https-rule"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "tomcat-rule"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
resource "azurerm_public_ip" "master" {
  name = "PublicIpMASTER"
  location = "westeurope"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
  allocation_method = "Dynamic"
  domain_name_label = "master-ssh"
}



resource "azurerm_lb" "mast_lb" {
  name = "load_balancer"
  location = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"

  frontend_ip_configuration{
      name = "PublicIpMASTER"
      public_ip_address_id = "${azurerm_public_ip.master.id}"
  }
}
resource "azurerm_lb_rule" "mast_lb_rl443" {
    resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
    loadbalancer_id = "${azurerm_lb.mast_lb.id}"
    name = "OpenshiftAdminConsole"
    protocol = "Tcp"
    frontend_port = 443
    backend_port = 443
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.backendpool.id}"
    frontend_ip_configuration_name = "PublicIpMASTER"
    probe_id = "${azurerm_lb_probe.probe_mast443.id}"
}

resource "azurerm_lb_rule" "mast_lb_rl8443" {
    resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
    loadbalancer_id = "${azurerm_lb.mast_lb.id}"
    name = "tomcatopenshiftadmin"
    protocol = "Tcp"
    frontend_port = 8443
    backend_port = 8443
    backend_address_pool_id = "${azurerm_lb_backend_address_pool.backendpool.id}"
    frontend_ip_configuration_name = "PublicIpMASTER"
    probe_id = "${azurerm_lb_probe.probe_mast8443.id}"
}

resource "azurerm_lb_probe" "probe_mast443" {
    resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
    loadbalancer_id = "${azurerm_lb.mast_lb.id}"
    name = "con-prob"
    port = 443
}

resource "azurerm_lb_probe" "probe_mast8443" {
    resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
    loadbalancer_id = "${azurerm_lb.mast_lb.id}"
    name = "tomcat-prob"
    port = 8443
}


resource "azurerm_lb_backend_address_pool" "backendpool" {
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
  loadbalancer_id     = "${azurerm_lb.mast_lb.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_rule" "natssh" {
  resource_group_name            = "${data.azurerm_resource_group.rgsab.name}"
  loadbalancer_id                = "${azurerm_lb.mast_lb.id}"
  name                           = "sshAccess"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIpMASTER"
}


resource "azurerm_network_interface" "master" {
  name                = "${var.prefix}-nic"
  location            = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
  
  

  ip_configuration {
    name                          = "master-config"
    subnet_id                     = "${azurerm_subnet.subnet_config.id}"
    private_ip_address_allocation = "Dynamic"
 
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "assocnetwpool" {
  network_interface_id = "${azurerm_network_interface.master.id}"
  ip_configuration_name = "master-config"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.backendpool.id}"
}

resource "azurerm_network_interface_security_group_association" "assocnicsec" {
  network_interface_id      = "${azurerm_network_interface.master.id}"
  network_security_group_id = "${azurerm_network_security_group.master.id}"
}

resource "azurerm_network_interface_nat_rule_association" "natrlasmas" {
  network_interface_id  = "${azurerm_network_interface.master.id}"
  ip_configuration_name = "master-config"
  nat_rule_id           = "${azurerm_lb_nat_rule.natssh.id}"
}
resource "azurerm_virtual_machine" "master" {
  name                  = "${var.prefix}-vm"
  location              = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name   = "${data.azurerm_resource_group.rgsab.name}"
  network_interface_ids = ["${azurerm_network_interface.master.id}"]
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  vm_size               = "Standard_B4ms"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

   

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOs"
    sku       = "7.7"
    version   = "latest"
  }
  storage_os_disk {
    name              = "masterintern-storage"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    

  }

  storage_data_disk {
    name = "datadisk"
    create_option="Empty"
    managed_disk_type = "Standard_LRS"
    disk_size_gb = 300
    lun = 0

  }
  os_profile {
    computer_name  = "master-vm"
    admin_username = "testadmin"
    admin_password = "Test123"

  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/testadmin/.ssh/authorized_keys"
      key_data = "${data.local_file.publicKey.content}"
          }
  }
  
  tags = {
    environment = "staging"
  }

}