Vagrant::Config.run do |config|

  config.vm.define :hlds do |hlds_config|
    hlds_config.vm.box = "hlds"
    hlds_config.vm.box_url = "$HOME/iso/squeeze64.box"
    hlds_config.vm.network :hostonly, "192.168.45.11"
    # If additional memory is needed
    # app_config.vm.customize ["modifyvm", :id, "--memory", 1024]
  end

  config.vm.define :mysql do |mysql_config|
    mysql_config.vm.box = "mysql"
    mysql_config.vm.box_url = "$HOME/iso/lucid64.box"
    mysql_config.vm.network :hostonly, "192.168.45.50"
  end

end
