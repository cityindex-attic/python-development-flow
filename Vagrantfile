Vagrant.configure("2") do |config|                                                                                                                                                        
  config.vm.box = "precise-server-cloudimg-amd64-vagrant-20130509"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/20130509/precise-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 4567, host: 4567
  config.vm.network :forwarded_port, guest: 5000, host: 5000

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision :shell, :path => "provision.sh"
end

