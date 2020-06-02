resource "azurerm_virtual_network" "virtualnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
}


resource "azurerm_subnet" "subnet_config" {
  name                 = "internal"
  resource_group_name  = "${data.azurerm_resource_group.rgsab.name}"
  virtual_network_name = "${azurerm_virtual_network.virtualnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "subnet_configWorker" {
  name                 = "internalworker"
  resource_group_name  = "${data.azurerm_resource_group.rgsab.name}"
  virtual_network_name = "${azurerm_virtual_network.virtualnet.name}"
  address_prefix       = "10.0.3.0/24"
}

resource "azurerm_availability_set" "avset" {

  name = "MultipleVms"
  location = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
  managed = true
}

resource "azurerm_availability_set" "avsetinfra" {
  name = "VMsWorkinfra"
  location = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
  managed = true
}


resource "azurerm_availability_set" "avsetwork" {
  name = "VMsWork"
  location = "${data.azurerm_resource_group.rgsab.location}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
  managed = true
}


data "template_file" "hosts"{

  template="${file("../template/hosts.tpl")}"
  depends_on=[
    "azurerm_virtual_machine.master",
    
  ]
  vars={
    infra_ip="${azurerm_public_ip.infra.ip_address}"
    cloudprovider="${var.cloudprovider}"
    subscription_id ="${var.subscriptionid}"
    tenant_id = "${var.tenantid}"
    client_id = "${var.clientid}"
    client_secret="${var.client_secret}"
    resource_group_name= "${data.azurerm_resource_group.rgsab.name}"
    hostname_cluster = "${var.hostname}"

    masters = "${join("\n", formatlist("%s ansible_ssh_private_key_file=%s", azurerm_virtual_machine.master.*.name, var.pk_ansible_key ))}"
    etcd = "${join("\n", formatlist("%s ansible_ssh_private_key_file=%s", azurerm_virtual_machine.infra.*.name, var.pk_ansible_key ))}"
    master_node = "${join("\n", formatlist("%s openshift_node_group_name='node-config-master' ansible_ssh_private_key_file=%s", azurerm_virtual_machine.master.*.name, var.pk_ansible_key))}"
    infra_node = "${join("\n", formatlist("%s openshift_node_group_name='node-config-infra' ansible_ssh_private_key_file=%s", azurerm_virtual_machine.infra.*.name, var.pk_ansible_key))}"
    worker_node = "${join("\n", formatlist("%s openshift_node_group_name='node-config-compute' ansible_ssh_private_key_file=%s", azurerm_virtual_machine.worker.*.name, var.pk_ansible_key))}"
  }
}

resource "local_file" "inventory_local" {
  content = "${data.template_file.hosts.rendered}"
  filename = "hosts"
}


#transform template file
resource "null_resource" "inventory" {
  triggers = {
    template = "${data.template_file.hosts.rendered}"
  }

# place template file in the vm 
  provisioner "file"{

    source = "hosts"
    destination = "/home/testadmin/hosts"

    connection{
      type     = "ssh"
      user     = "testadmin"
      host = "${var.hostname}"
      private_key = "${data.local_file.privateKey.content}"
    }
  }

  provisioner "remote-exec" {
        connection {

            type     = "ssh"
            user     = "testadmin"
            host = "${var.hostname}"
            private_key = "${data.local_file.privateKey.content}"
        }
        script = "../install_package.sh"
   }
}

