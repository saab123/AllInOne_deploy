
variable "prefix" {
  default = "master"
}

variable "prefix-infra" {
  default = "infra"
}

variable "prefix-worker" {
  default = "worker"
}

variable "hostname" {
  default = "master-ssh.westeurope.cloudapp.azure.com"
}

variable "cloudprovider" {
  default= "azure"
}

variable "subscriptionid" {
  default = "4760579d-6e21-4a51-988b-54af405584f4"
}

variable "tenantid" {
  default = "d018aec4-2b2b-4c66-9939-2c96877e6bf1"
}
variable "clientid" {
  default = "da865e5e-111a-4822-bfcf-3852f65fc8c4"
}
variable "client_secret" {
  default = "InO8zh=sq1/=cVKvMTRDWq=F3OiT2aQ6"
}

data "local_file" "privateKey" {
  filename = "../key/ssh-key"
}

variable "pk_ansible_key" {
  default = "/home/testadmin/gitlabpipeline/key/ssh-key"
}


data "local_file" "publicKey" {
  filename = "../key/ssh-key.pub"
}



