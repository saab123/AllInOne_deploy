[OSEv3:children]
masters
etcd
nodes

[OSEv3:vars]

ansible_ssh_user=testadmin
ansible_become=true
openshift_deployment_type=origin
openshift_release=v3.11

#Azure_cloud_openshift
openshift_cloudprovider_kind=${cloudprovider}
openshift_cloudprovider_azure_client_id=${client_id}
openshift_cloudprovider_azure_client_secret=${client_secret}
openshift_cloudprovider_azure_tenant_id=${tenant_id}
openshift_cloudprovider_azure_subscription_id=${subscription_id}
openshift_cloudprovider_azure_resource_group=${resource_group_name}
openshift_cloudprovider_azure_location=westeurope
openshift_storageclass_parameters={'kind': 'managed', 'storageaccounttype': 'Premium_LRS'}
openshift_disable_check=memory_availability,disk_availability
openshift_master_default_subdomain=apps.${infra_ip}.xip.io
openshift_master_cluster_public_hostname=${hostname_cluster}

#webconsole
openshift_web_console_install=true
openshift_master_api_port=8443
openshift_master_console_port=8443

# htpasswd auth
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
# Defining htpasswd users
openshift_master_htpasswd_users={'admintest': '$apr1$nk2gtbow$bLNo8pcfHMbb5FgDv3yQV/', 'tester': '$apr1$ojcr8d3u$7q1NPiAABJj7ioOQHCu3M.'}

[masters]
${masters}

[etcd]
${etcd}

[nodes]
${master_node}
${infra_node}
${worker_node}
