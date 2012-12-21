Capistrano::Configuration.instance(true).load do

  task :vagrant do
  # make empty roles
  roles[:app]
  roles[:hlds]
  roles[:nagios]
  roles[:mysqld]
  roles[:mysql_master]
  roles[:postfix_client]
  roles[:redis]
  roles[:rsyslog_server]
  roles[:rsyslog_client]
  roles[:chef_server]
  roles[:chef_client]

    ENV['NOTIFY']='0'
    set :rails_env, :development
    set :bundler_opts, %w(--deployment --no-color)
    set :target_os, :ubuntu64
    ssh_options[:forward_agent] = true
    ssh_options[:paranoid] = false
    # ssh_options[:keys] = `vagrant ssh_config | grep IdentityFile`.split.last
    ssh_options[:keys] = ["#{`bundle show vagrant`.strip}/keys/vagrant"]
    set :sudoers_file, File.join(File.dirname(__FILE__), '..', 'ssh', 'vagrant')
    set :run_method, :sudo
    set :god_notify_list, "localhost"
    set :god_git_ref, "v0.13.1"
    set :database_host, "10.0.2.15"
    # Chef
    set :nginx_cert_name, "sysadminpunk.com"
    set :nginx_server_name, "chef.sysadminpunk.com"
    set :chef_listen_port, "4040"
    set :application, "chef_server"
    set :nginx_bind_eth, "eth0"
    set :nginx_app_conf_path, File.join(File.dirname(__FILE__),'..','nginx','chef.app.conf.erb')
    set(:chef_server_validation_pem, File.join(File.dirname(__FILE__), "..", "chef", "keys", "dc3-validation.pem"))

    # MySQL
    set :mysql_listen_interface, "eth0"
    set :mysql_data_dir, "/var/lib/mysql"
    set :mysql_log_dir, "/var/log/mysql"
    set :mysql_listen, "###ETH###"
    set :mysql_max_connections, "250"
    set :mysql_innodb_thread_concurrency, "2"
    set :mysql_innodb_buffer_pool_size, "256MB"
    set :mysql_conf, File.join(File.dirname(__FILE__), '..', 'mysql', 'my.cnf.erb')
    set :mysql_backup_script, File.join(File.dirname(__FILE__), '..', 'mysql', 'mysql_backup_outfile.sh')
    set :mysql_backup_script_path, "/root/script/mysql_backup_outfile.sh"
    set :mysql_restore_script, File.join(File.dirname(__FILE__), '..', 'mysql', 'mysql_restore_outfile.sh')
    set :mysql_restore_script_path, "/root/script/mysql_restore_outfile.sh"
    set :mysql_restore_source_name, "gamehost_prod"
    set :mysql_restore_table_priorities, ""
    set :mysql_backup_location, "/backups/mysql"

    # Servers
    # Servers - (List should be self explanatory.  Whilst testing, comment out the servers you aren't using)
    server "192.168.45.7",  :app, :resque_web, :newrelic_sysmond, :postfix_client,  :no_denyhosts => true
    server "192.168.45.10", :postfix_client, :pflogsumm, :dovecot, :dkim_filter, :dk_filter, :monit, :nginx, :no_release => true, :no_denyhosts => true, :no_ruby => true
    server "192.168.45.16", :nginx, :no_release => true, :no_denyhosts => true, :no_ruby => true
    server "192.168.45.20", :worker, :postfix_client,  :no_denyhosts => true
    server "192.168.45.50", :mysqld, :db, :mysqld_innobackupex, :redis, :no_release => true, :no_denyhosts => true, :no_ruby => true

  end

end
