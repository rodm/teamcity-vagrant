#
# TeamCity Server and Agent VMs configured using shell scripts
#

domain = 'localdomain'

box = 'precise32'
box_url = 'http://files.vagrantup.com/precise32.box'

nodes = [
  { :hostname => 'teamcity', :ip => '192.168.80.10', :ram => '2048' },
  { :hostname => 'agent01',  :ip => '192.168.80.11', :ram => '2048' },
  { :hostname => 'agent02',  :ip => '192.168.80.12', :ram => '2048' },
  { :hostname => 'agent03',  :ip => '192.168.80.13', :ram => '2048' }
]

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  nodes.each do | node |
    config.vm.define node[:hostname] do | node_config |
      node_config.vm.box = box
      node_config.vm.box_url = box_url

      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      memory = node[:ram] ? node[:ram] : 256

      node_config.vm.provider :virtualbox do | vbox |
        vbox.gui = false
        vbox.customize ['modifyvm', :id, '--name', node[:hostname]]
        vbox.customize ['modifyvm', :id, '--memory', memory.to_s]
      end

      node_config.vm.provider 'vmware_fusion' do | vmware |
        vmware.gui = false
        vmware.vmx['memsize'] = memory.to_s
      end

      node_config.vm.provider 'vmware_workstation' do | vmware |
        vmware.gui = false
        vmware.vmx['memsize'] = memory.to_s
      end

      node_config.vm.provision :shell do | shell |
        shell.path = 'scripts/setup.sh'
      end
    end
  end
end
