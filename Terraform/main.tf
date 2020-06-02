provider "azurerm" {
  features {}
  subscription_id = "${var.subscriptionid}"
  client_id = "${var.clientid}"
  client_secret = "${var.client_secret}"
  tenant_id       = "${var.tenantid}"
  version = "~> 2.0"
}

data "azurerm_resource_group" "rgsab" {
  name = "RG-Lab-SabriHendrick"
 
}

resource "azurerm_storage_account" "openshift" {
  name = "openshift${lower(replace(substr(uuid(), 0, 10), "-", ""))}"
  resource_group_name = "${data.azurerm_resource_group.rgsab.name}"
  location = "${data.azurerm_resource_group.rgsab.location}"
  account_tier = "Premium"
  account_replication_type = "LRS"
}


