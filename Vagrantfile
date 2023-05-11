# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "debian/bullseye64"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # Disable default vagrant share
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # Provider-specific configuration so you can fine-tune VirtualBox
  # provider for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    # Name the prototype machine
    vb.name = "DDHN v1.1 RC2"
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
    # Customize the CPUs (2x) and memory (4GB) on the VM:
    vb.cpus = 2
    vb.memory = "4096"
    # Now set an execution cap at 50 % if required
    # vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    # We need extra Video RAM for display flexibility
    vb.customize ["modifyvm", :id, "--vram", "128"]
    # Set up bi-directional clipboard plus drag and drop
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
  end

  # Enable provisioning with local ansible playbook.
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/initialise-env.yml"
    ansible.verbose = "vv"
    ansible.limit = "env.ddhn.test"
    ansible.galaxy_role_file = "ansible/requirements.yml"
    ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file}"
    ansible.inventory_path = "ansible/vagrant.yml"
  end
end
