# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"
  config.vm.define "ubuntu18-bionic64"
  config.vm.synced_folder "salt/roots/", "/srv/salt/"
  
  config.vm.provider :virtualbox do |vb|
    vb.name = "ubuntu18-bionic64"
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end

  config.ssh.insert_key = false

  config.vm.provision :salt do |salt|

    salt.minion_config = "salt/minion.yml"
    salt.log_level = 'info'
    salt.run_highstate = true
    salt.colorize = true
    salt.verbose = true

  end

  config.vm.post_up_message = <<-HEREDOC
  ------------------------------------------------------
  
  Congratulations!

  Your vagrant box is prepared.

  To log into it, run:

      vagrant ssh

  ------------------------------------------------------
  HEREDOC

end
