$ProjectName = 'master'

VAGRANTFILE_API_VERSION = "2"

$script = <<SCRIPT
apt-get update
apt-get install -y puppet
cd /vagrant
puppet module install puppetlabs-apt
puppet apply server.pp
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

 
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true

  # fixes  Warning: Authentication failure. Retrying... 1.8.5 bug
  # config.ssh.insert_key = false

  config.vm.define "server1" do |server1| 
    server1.vm.box = "bento/ubuntu-16.10"
    server1.vm.hostname = "server1.colo.seagate.com"
    server1.vm.network :private_network, ip: "10.0.0.15"
    server1.vm.network "forwarded_port", guest: 5601, host: 5601
    server1.vm.provision "shell", inline: $script
    server1.vm.provider "virtualbox" do |v|
      v.memory = 6024
      v.cpus = 2
    end
  end


end
