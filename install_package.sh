echo "Starting Script"
sudo yum -y update
sudo yum -y install epel-release 
sudo yum -y install python
sudo yum -y install ansible 
sudo yum -y install git
git clone https://oauth2:JbFTxykCdfeyyBPpvPnj@odyssey.devoteam.be/Saab123/gitlabpipeline.git
cd gitlabpipeline
git checkout dev
cd Ansible
 sudo wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
 sudo tar -xvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
 cd openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit
 sudo mv oc kubectl /usr/bin/
 cd ~/gitlabpipeline/
 sudo chmod 700 key/
 sudo chmod 700 key/ssh-key key/ssh-key.pub
 sudo cp /home/testadmin/hosts /etc/ansible/hosts
 sudo cp /home/testadmin/gitlabpipeline/Ansible/ansible.cfg /etc/ansible/ansible.cfg
 sudo ansible-playbook -i /etc/ansible/hosts Ansible/playbook.yml --ssh-common-args='-o StrictHostKeyChecking=no'
 sudo ansible-playbook -i /etc/ansible/hosts openshift/playbooks/prerequisites.yml --ssh-common-args='-o StrictHostKeyChecking=no'
 sudo ansible-playbook -i /etc/ansible/hosts openshift/playbooks/deploy_cluster.yml --ssh-common-args='-o StrictHostKeyChecking=no'

sudo oc adm policy add-cluster-role-to-user cluster-admin admintest