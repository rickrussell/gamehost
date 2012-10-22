require 'digest/md5'

Capistrano::Configuration.instance(true).load do

  namespace :ssh do
    set :infrastructure_checkout, "/home/dev/infrastructure/current"
    set :ssh_public_keys_root, File.join(File.dirname(__FILE__),"public_keys_stages")
    set(:ssh_public_keys_stage) { rails_env.to_s }
    set(:ssh_public_keys_dir) {File.join(ssh_public_keys_root, ssh_public_keys_stage)}
    set :ssh_sshd_config_erb, File.join(File.dirname(__FILE__),"sshd_config.erb")
    set :issue_net, File.join(File.dirname(__FILE__),'issue.net')
    set :ssh_users_global_sunset, File.join(File.dirname(__FILE__),'users_global_sunset')
    #remove ltabb lloyd.tabb@gmail.com after staging2 llooker project is done; remove him from the server too.
    set :ssh_user_whitelist, %w(dev root ubuntu repl jenkins vagrant looker)
    set(:ssh_dev_key_root) {File.join(File.dirname(__FILE__), "public_keys")}
    set :ssh_dev_key, "dev.pub"
    set(:ssh_dev_key_path) {File.join(ssh_dev_key_root, ssh_dev_key)}
    set :dev_password, nil
    set :ssh_password_authentication, false

    # Make sure this is done before all of the provision hooks
    on :start, :only => "deploy:provision" do
      ssh.install
    end

    # Original Implementation of the predictable_user_id in infrastructure
    # # Get the ASCII decimal equiv of a character
    # function ord() {
    #   printf '%d' "'$1"
    #
    #
    # # We want a predictable uid and gid so that nfs user and groups can match across servers.
    # function id() {
    #     RV=1000
    #     EXEMPLAR=`echo $(echo donovan | md5sum) | awk -v ORS="" '{ gsub(/./,"&\n") ; print }'`
    #     for CHR in ${EXEMPLAR}
    #     do
    #         RV=`expr ${RV} + $(ord ${CHR})`
    #     done
    #     echo ${RV}
    # }

    #TODO: this is matching the original implementation, above but isn't matching the historical id's.
    # Will proceed with this implementation because we currently aren't using nfs.
    #TODO: this formula has collisions:
    # (Digest::MD5.hexdigest(uname+"\n")).each_char.inject(1000){|m,c| m + c[0].to_i}
    # p predictable_user_id('bwoods') => 3020
    # p predictable_user_id('mwaterfield') => 3020

    def predictable_user_id(uname)
      (Digest::MD5.hexdigest(uname+"\n")).each_char.inject(1000){|m,c| m + c[0].to_i}
    end

    def initial_pw(uname)
      # PASSWORD=`echo ${USER} | md5sum | cut -c 1-8`
      Digest::MD5.hexdigest(uname)[0..12]
    end

    # bin/cap production_sc4 ssh:asme ssh:recreate_dev ssh:install
    desc "Use Alternate ENV['USER'] credentials to do task"
    task :asme do
      set :user, ENV['USER']
      set(:password) { Capistrano::CLI.password_prompt }
    end

    task :install do
      sudoers.install
      ssh.create_dev
      #ssh.users_global_sunset #cull_unknown_users will catch these.
      ssh.cull_unknown_users
      ssh.update_users
      denyhosts.install
      ssh.setup #may loose connectivity after this statement
      ssh.disable_root_pw #may loose connectivity after this statement
      ssh.install_issue
      ssh.disable_empty_passwords
    end

    task :users_global_sunset do
      #Remove all known sunset users.
      Dir.glob(File.join(ssh_users_global_sunset,'*')).each do |uname|
        run "#{sudo} deluser --force --remove-home #{File.basename(uname)}; true"
      end
    end

    task :cull_unknown_users do
      #we probably need the per server pattern for this
      known_users = []
      %w(sysops developers restricted).each do | primary_group |
        Dir.glob(File.join(ssh_public_keys_dir,primary_group,"*")).each do |pkname|
          known_users << key_username(pkname)
        end
      end
      remote_users = capture(%Q{#{sudo} cat /etc/shadow | grep -e '^[^:]*[^!\*]*$' | cut -d: -f1}).split("\n").map(&:strip)
      unknown_users = ((remote_users - known_users ) - ssh_user_whitelist).reject(&:empty?)
      unknown_users.each do |unknown|
        run "#{sudo} deluser --force --remove-home #{unknown}; true" unless ssh_user_whitelist.include?(unknown)
      end
    end

    task :show_unknown_users do
      #we probably need the per server pattern for this
      known_users = []
      %w(sysops developers restricted).each do | primary_group |
        Dir.glob(File.join(ssh_public_keys_dir,primary_group,"*")).each do |pkname|
          known_users << key_username(pkname)
        end
      end
      remote_users = capture(%Q{#{sudo} cat /etc/shadow | grep -e '^[^:]*[^!\*]*$' | cut -d: -f1}).split("\n").map(&:strip)
      unknown_users = ((remote_users - known_users ) - ssh_user_whitelist).reject(&:empty?)
      puts y(unknown_users)
    end

    task :setup do
      utilities.sudo_upload_template ssh_sshd_config_erb, "/etc/ssh/sshd_config", :owner => "root:root", :mode => "0644"
    end

    # Now deprecated as we push the sudoers template that we want.
    task :update_sudoers do
      # WE SHOULD NOT NEED THIS IN THE FUTURE
      utilities.run_compressed %Q{
        if [ "`#{sudo} grep -c "SSH_AUTH_SOCK" /etc/sudoers`" -eq "0" ]; then
          #{sudo} sh -c "echo Defaults env_keep='SSH_AUTH_SOCK' >> /etc/sudoers";
        fi;
        if [ "`#{sudo} grep -c "%admin" /etc/sudoers`" -eq "0" ]; then
          #{sudo} sh -c "echo '%admin ALL=(ALL) ALL' >> /etc/sudoers";
        fi;
      }
    end

    task :disable_password_auth do
      utilities.run_compressed %Q{
        #{sudo} cp /etc/ssh/sshd_config /etc/ssh/sshd_config.`date +%s` &&
        #{sudo} grep -v PasswordAuthentication /etc/ssh/sshd_config > /tmp/sshd_config.new &&
        #{sudo} echo "PasswordAuthentication no" >> /tmp/sshd_config.new &&
        #{sudo} mv /tmp/sshd_config.new /etc/ssh/sshd_config &&
        #{sudo} /etc/init.d/ssh restart
      }
    end

    task :disable_empty_passwords do
      utilities.run_compressed %Q{
        #{sudo} cp /etc/ssh/sshd_config /etc/ssh/sshd_config.`date +%s` &&
        #{sudo} grep -v PermitEmptyPasswords /etc/ssh/sshd_config > /tmp/sshd_config.new &&
        #{sudo} echo "PermitEmptyPasswords no" >> /tmp/sshd_config.new &&
        #{sudo} mv /tmp/sshd_config.new /etc/ssh/sshd_config &&
        #{sudo} /etc/init.d/ssh restart
      }
    end

    desc "disable root pw"
    task :disable_root_pw do
      run "#{sudo} usermod -p '!' root"
      run "#{sudo} usermod -p '!' ubuntu; true"
    end

    # Change stages to target the new servers,
    # set the following, then run ssh:create_dev
    # set :user, "whatver"
    # set :password, "whatever"
    # set :dev_password, "whatever"
    # After ssh:create_dev has run you should be able to run the normal deploy scripts
    # TODO: probably need to create another top level task that describes, pre-provisioning
    # ie getting our dev user on it and adding it's keys or maybe as long as it's not destructive
    # it should be hooked in for deploy:provision
    # removed configuring git in the create_dev

    task :create_dev do
      username = 'dev'
      # This code is different for dev as it doesn't set a default password; and
      # it attempts to correct a previously created dev account that has one.
      # you must have a sudoers that allows dev to do commands without a password challenge.
      utilities.run_compressed %Q{
        #{sudo} adduser --gecos "" --disabled-password #{username};
        #{sudo} passwd --delete #{username};
        #{sudo} chown -R #{username}:#{username} /home/#{username};
        #{sudo} mkdir -p /home/#{username}/.ssh;
        #{sudo} touch /home/#{username}/.ssh/authorized_keys;
        #{sudo} chown -R #{username}:#{username} /home/#{username}/.ssh;
        #{sudo} chmod -R u=rwX,go= /home/#{username}/.ssh;
      }
      utilities.sudo_upload ssh_dev_key_path, "/home/#{username}/.ssh/authorized_keys", :owner => "#{username}:#{username}", :mode => "0600"
      run %Q{#{sudo} sh -c 'echo "#{username}:#{dev_password}" | chpasswd'} if dev_password
    end

    task :recreate_dev do
      run "#{sudo} pkill -u dev; #{sudo} deluser --force dev; #{sudo} delgroup --force dev;true"
      create_dev
    end

    def key_username(path)
      path.match(/([^\/]*)\.pub/)[1].downcase
    end

    #Now Excludes keys not explicitly defined.
    def update_user_from_key(pkname, primary_group, create_or_append = ">")
      username = key_username(pkname)
      #puid = predictable_user_id(username)
      ipw = initial_pw(username)
      # removed email component. This was the original line.  all key owners don't have emails @homerun.com anymore.
      #        #{sudo} adduser --gecos "" --uid #{puid} --gid #{puid} --disabled-password #{username} && #{sudo} sh -c 'echo "#{username}:#{ipw}" | chpasswd' && #{sudo} passwd --expire #{username} && echo "Your initial password for #{username}@`hostname` is '#{ipw}'" | mailx -s "initial user password for `hostname`" #{username}@homerun.com;
      # removed the  predictable_user_id they weren't guaranteed to be unique.
      utilities.run_compressed %Q{
        #{sudo} adduser --gecos "" --disabled-password #{username} && #{sudo} sh -c 'echo "#{username}:#{ipw}" | chpasswd' && #{sudo} passwd --expire #{username};
        #{sudo} adduser #{username} #{primary_group};
        #{sudo} addgroup #{username};
        #{sudo} adduser #{username} #{username};
        #{sudo} mkdir -p /home/#{username}/.ssh;
        #{sudo} touch /home/#{username}/.ssh/authorized_keys;
        #{sudo} chmod -R u=rwX,go= /home/#{username}/.ssh;
        #{sudo} chown -R #{username}:#{username} /home/#{username};
      }
      utilities.sudo_upload(pkname, "/home/#{username}/.ssh/authorized_key.new")
      sudo %Q{ sh -c 'cat /home/#{username}/.ssh/authorized_key.new #{create_or_append} /home/#{username}/.ssh/authorized_keys; rm -f /home/#{username}/.ssh/authorized_key.new' }
    end

    desc "update users based on public keys"
    task :update_users do
      ssh.disable_password_auth #ensure password auth is always disabled
      users_done = {}
      %w(sysops developers restricted).each do | primary_group |
        Dir.glob(File.join(ssh_public_keys_dir,primary_group,"*")).each do |pkname|
          next if pkname.match(/\/dev\./)
          user = key_username(pkname)
          update_user_from_key pkname, primary_group, users_done[user].nil? ? ">" : ">>"
          users_done[user]=true  #updates the hash to track if a user has already had at least one key placed onto the box.
        end
      end
    end

    task :ipw do
      logger.info "IPW for #{ENV['USER']} : #{initial_pw(ENV['USER'])}"
    end

    namespace :uladmin do
      task :enable do
        sudo "passwd uladmin -u"
        sudo "mkdir -p /home/uladmin/.ssh"
        sudo "chown -R uladmin:uladmin /home/uladmin/"
        utilities.sudo_upload File.join(File.dirname(__FILE__),'public_keys_special','uladmin.pub'), '/home/uladmin/.ssh/authorized_keys', :owner => 'uladmin:uladmin', :mode => "600"
      end
      task :disable do
        sudo "passwd uladmin -l"
      end
    end

  end
end
