# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
    
  config.ssh.insert_key = false

  config.vm.define "docker" do |docker|
    docker.vm.box = "shekeriev/centos-stream-9"
    docker.vm.hostname = "docker.do2.lab"
    docker.vm.network "private_network", ip: "192.168.99.100"
    docker.vm.network "forwarded_port", guest: 80, host: 8000

    docker.vm.provision "shell", inline: <<EOS
echo "* Add EPEL repository ..."
dnf install -y epel-release

echo "* Install Python3 ..." 
dnf install -y python3 python3-pip

echo "* Install Python docker module ..."
pip3 install docker

echo "* Install utils ..."
sudo yum install -y yum-utils

echo "*Add repository ..." 
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

echo "* Install Terraform  ..."
sudo yum -y install terraform

echo "# Open some ports"
firewall-cmd --add-port 3000/tcp --permanent
firewall-cmd --add-port 9090/tcp --permanent
firewall-cmd --add-port 15672/tcp --permanent
firewall-cmd --add-port 15692/tcp --permanent
firewall-cmd --add-port 9092/tcp --permanent
firewall-cmd --add-port 5672/tcp --permanent
firewall-cmd --add-port 5000/tcp --permanent
echo "# Reload the configuration"
firewall-cmd --reload
EOS

    docker.vm.provision "ansible_local", :run => 'always' do |ansible|
      ansible.become = true
      ansible.install_mode = :default
      ansible.playbook = "/vagrant/ansible/playbook.yml"
      ansible.galaxy_role_file = "/vagrant/ansible/requirements.yml"
      ansible.galaxy_roles_path = "/etc/ansible/roles"
      ansible.galaxy_command = "sudo ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"
    end
  end
  $puppetrpm = <<PUPPETRPM
  sudo dnf install -y https://yum.puppet.com/puppet7-release-el-8.noarch.rpm
  sudo dnf install -y puppet
PUPPETRPM

$modulesweb = <<MODULESWEB
  puppet module install puppetlabs-firewall
  puppet module install puppet-selinux --version 3.4.1
  puppet module install puppetlabs-vcsrepo
  sudo cp -vR ~/.puppetlabs/etc/code/modules/ /etc/puppetlabs/code/
MODULESWEB
  
$modulesdb = <<MODULESDB
  puppet module install puppetlabs-vcsrepo
  puppet module install puppetlabs/mysql
  puppet module install puppetlabs-firewall
  puppet module install puppet-selinux --version 3.4.1
  sudo cp -vR ~/.puppetlabs/etc/code/modules/ /etc/puppetlabs/code/
MODULESDB

config.vm.define "web" do |web|
  web.vm.box = "shekeriev/centos-stream-8"
  web.vm.hostname = "web.do2.lab"
  web.vm.network "private_network", ip: "192.168.99.101"
  web.vm.provision "shell", inline: $puppetrpm, privileged: false
  web.vm.provision "shell", inline: $modulesweb, privileged: false
  
  web.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "web.pp"
    puppet.options = "--verbose --debug"
  end
end

config.vm.define "db" do |db|
  db.vm.box = "shekeriev/centos-stream-8"
  db.vm.hostname = "db.do2.lab"
  db.vm.network "private_network", ip: "192.168.99.102"
  db.vm.provision "shell", inline: $puppetrpm, privileged: false
  db.vm.provision "shell", inline: $modulesdb, privileged: false

  db.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file = "db.pp"
    puppet.options = "--verbose --debug"
    end
  end
end
