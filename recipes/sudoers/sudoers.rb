Capistrano::Configuration.instance(true).load do

  namespace :sudoers do
    set :sudoers_file, File.join(File.dirname(__FILE__),'development')
    #set :sudoers_file, File.join(File.dirname(__FILE__),'simple') # the other sudoers doesn't allow apt-get to work yet

    def sudoers_group_members(group)
      Dir.glob(File.join(ssh_public_keys_dir,group,"*")).map{ |pkname| File.basename(pkname).split('.').first}.uniq.join(",")
    end

    set(:sudoers_sysops) { sudoers_group_members('sysops') }
    set(:sudoers_developers){ sudoers_group_members('developers') }
    set(:sudoers_restricted){ sudoers_group_members('restricted') }

    # sudoers.install now driven by ssh

    # # Make sure this is done before all of the provision hooks
    # on :start, :only => "deploy:provision" do
    #   sudoers.install
    # end

    desc "Install sudeoers file"
    task :install do
      sudoers.pam_admin_su
      utilities.upload_template sudoers_file, "/tmp/sudoers"
      utilities.run_compressed %Q{
        #{sudo} cp /etc/sudoers /etc/sudoers.`date +%s`;
        #{sudo} chown root:root /tmp/sudoers;
        #{sudo} chmod 0440 /tmp/sudoers;
        #{sudo} visudo -c -f /tmp/sudoers;
        #{sudo} mv /tmp/sudoers /etc/sudoers;
        #{sudo} addgroup sysops;
        #{sudo} addgroup restricted;
        #{sudo} addgroup developers;
        #{sudo} deluser dev admin;
        true;
      }
    end

    desc "Allow admin group to su"
    task :pam_admin_su do
      sudo "sed -i 's/#.*auth.*required.*pam_wheel.so$/auth       required   pam_wheel.so group=admin/' /etc/pam.d/su"
    end

  end

end