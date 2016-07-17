#
# TeamCity Server and Agent VMs configured using shell scripts
#

domain = 'localdomain'

precise64_box = 'precise64'
precise64_url = 'http://files.vagrantup.com/precise64.box'
centos64_box = 'centos64'
centos64_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box'

nodes = [
  { :hostname => 'teamcity', :ip => '192.168.80.10', :ram => '3072' },
  { :hostname => 'agent01',  :ip => '192.168.80.11', :ram => '2048' },
  { :hostname => 'agent02',  :ip => '192.168.80.12', :ram => '2048', :box => precise64_box, :url => precise64_url },
  { :hostname => 'agent03',  :ip => '192.168.80.13', :ram => '2048', :box => centos64_box, :url => centos64_url }
]

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  nodes.each do | node |
    config.vm.define node[:hostname] do | node_config |
      node_config.vm.box = node[:box] ? node[:box] : precise64_box
      node_config.vm.box_url = node[:url] ? node[:url] : precise64_url

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
