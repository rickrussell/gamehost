Vagrant::Config.run do |config|

  config.vm.define :hlds do |hlds_config|
    hlds_config.vm.box = "hlds"
    hlds_config.vm.box_url = "$HOME/iso/lucid64.box"
    hlds_config.vm.network :hostonly, "192.168.45.10"
    hlds_config.vm.customize ["modifyvm", :id, "--name", "hlds", "--memory", 1024]

    # Enable and configure the chef solo provisioner
    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ["cookbooks"]
      # Tell chef what recipe to run. In this case, the `vagrant_main` recipe
      # does all the magic.
      chef.add_recipe("apt")
      chef.add_recipe("build-essential")
      chef.add_recipe("users")
      chef.add_recipe("sudo")
      chef.add_recipe("mysql")
    end
  end

end
