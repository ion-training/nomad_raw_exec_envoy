# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
    config.vm.box = "hashicorp/bionic64"
  
    config.vm.define "server" do |server|
      server.vm.hostname = "server"
      server.vm.provision "shell", path: "scripts/server.sh"
      server.vm.network "private_network", ip: "192.168.56.71"
    end
  
  end