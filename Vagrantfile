#
# TeamCity Server and Agent VMs configured using shell scripts
#

Vagrant.configure("2") do | config |

  # TeamCity Build Server
  config.vm.define :teamcity do | config |
    #config.vm.box = "lucid32"
    config.vm.box = "precise32"
    #config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
    config.vm.box_url = "http://files.vagrantup.com/precise32.box"

    config.vm.hostname = "teamcity.localdomain"
    config.vm.network :private_network, ip: "192.168.80.10"

    config.vm.provider :virtualbox do | vbox |
      vbox.customize ["modifyvm", :id, "--name", "teamcity"]
      vbox.customize ["modifyvm", :id, "--memory", 2048]
    end

    config.vm.provision :shell do | shell |
      shell.path = "scripts/setup.sh"
    end
  end

  # TeamCity Build Agent - agent01
  config.vm.define :agent01 do | config |
    #config.vm.box = "lucid32"
    config.vm.box = "precise32"
    #config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
    config.vm.box_url = "http://files.vagrantup.com/precise32.box"

    config.vm.hostname = "agent01.localdomain"
    config.vm.network :private_network, ip: "192.168.80.11"

    config.vm.provider :virtualbox do | vbox |
      vbox.customize ["modifyvm", :id, "--name", "agent01"]
      vbox.customize ["modifyvm", :id, "--memory", 2048]
    end

    config.vm.provision :shell do | shell |
      shell.path = "scripts/setup.sh"
    end
  end

  # TeamCity Build Agent - agent02
  config.vm.define :agent02 do | config |
    #config.vm.box = "lucid32"
    config.vm.box = "precise32"
    #config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
    config.vm.box_url = "http://files.vagrantup.com/precise32.box"

    config.vm.hostname = "agent02.localdomain"
    config.vm.network :private_network, ip: "192.168.80.12"

    config.vm.provider :virtualbox do | vbox |
      vbox.customize ["modifyvm", :id, "--name", "agent02"]
      vbox.customize ["modifyvm", :id, "--memory", 2048]
    end

    config.vm.provision :shell do | shell |
      shell.path = "scripts/setup.sh"
    end
  end

  # TeamCity Build Agent - agent03
  config.vm.define :agent03 do | config |
    #config.vm.box = "lucid32"
    config.vm.box = "precise32"
    #config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
    config.vm.box_url = "http://files.vagrantup.com/precise32.box"

    config.vm.hostname = "agent03.localdomain"
    config.vm.network :private_network, ip: "192.168.80.13"

    config.vm.provider :virtualbox do | vbox |
      vbox.customize ["modifyvm", :id, "--name", "agent03"]
      vbox.customize ["modifyvm", :id, "--memory", 2048]
    end

    config.vm.provision :shell do | shell |
      shell.path = "scripts/setup.sh"
    end
  end
end
