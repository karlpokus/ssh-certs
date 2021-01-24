# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "ubuntu"
  config.vm.provision "shell", inline: <<-SHELL
    cp -v /vagrant/trusted-user-ca-keys.pem /vagrant/principals.sh /etc/ssh
    cp -v /vagrant/ca.conf /etc/ssh/sshd_config.d
    systemctl restart sshd
  SHELL
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end
