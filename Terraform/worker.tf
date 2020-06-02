


resource "azurerm_network_security_group" "worker" {
    count = 2
  name                = "acceptResourceGroupworker-${count.index + 1}"
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

}

/* resource "azurerm_public_ip" "worker" {
    name = "publicIpWorkerUN"
    location = "${data.azurerm_resource_group.rgsab.location}"
    resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
    allocation_method = "Dynamic"
    domain_name_label = "worker-ssh"
} */


resource "azurerm_network_interface" "worker" {
  count = 2
  name                = "${var.prefix-worker}-nic-${count.index + 1}"
  location            = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"

  ip_configuration {
    name                          = "worker-config-${count.index + 1}"
    subnet_id                     = "${azurerm_subnet.subnet_configWorker.id}"
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id = "${azurerm_public_ip.worker.id}"
  }
}
resource "azurerm_virtual_machine" "worker" {

  count                 = 2
  name                  = "worker-vm-${count.index + 1}"
  location              = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name   = "${data.azurerm_resource_group.rgsab.name}"
  network_interface_ids = ["${azurerm_network_interface.worker.*.id[count.index]}"]
  availability_set_id   = "${azurerm_availability_set.avsetwork.id}"
  vm_size               = "Standard_D2_v3"

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
    name              = "workerintern-storage-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name = "datadisk-${count.index + 1}"
    create_option="Empty"
    managed_disk_type = "Standard_LRS"
    disk_size_gb = 300
    lun = 0

  }
  os_profile {
    computer_name  = "worker-vm-${count.index + 1}"
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

}
