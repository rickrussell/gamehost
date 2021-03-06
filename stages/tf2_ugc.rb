Capistrano::Configuration.instance(true).load do

  task :tf2_ugc do
    # make empty roles
    roles[:hlds_ugc]

    ENV['NOTIFY']='0'
    set :rails_env, :hlds_ugc
    set :bundler_opts, %w(--deployment --no-color)
    set :target_os, :debian64
    ssh_options[:forward_agent] = true
    ssh_options[:paranoid] = false
    set :run_method, :sudo
    set :sudoers_file, File.join(File.dirname(__FILE__), '..', 'recipes', 'sudoers', 'tf2')
    set :ugc_files, File.join(File.dirname(__FILE__),  '..', 'recipes', 'hlds', 'ugc.tar')

    #HLDS Custom Settings (requires)
    set :fps_max, "1000"
    set :maxplayers, "18"
    set :server_port, "27015"
    set :hlds_mapcycle, %w(pl_swiftwater_ugc)
    set :server_type_cfg, "ugc_HL_stopwatch.cfg" # "server.cfg" (default), "ugc_HL_standard" (standard), "ugc_HL_koth.cfg" (King of the Hill), "ugc_HL_dom.cfg" (Domination), "ugc_HL_ctf.cfg" (CTF)
    set(:sudeors_username) {secrets.sudeors_credentials[:username]}
    set(:chef_password) {secrets.chef[:password]}
    set(:server_ip) {secrets.tf2_ugc[:server_ip]}
    set(:hlds_config_hostname) {secrets.tf2_ugc[:hostname]}
    set(:hlds_config_sv_contact) {secrets.tf2_ugc[:sv_contact]}
    set(:hlds_config_tf_server_identity_account_id) {secrets.tf2_ugc[:identity_account_id]}
    set(:hlds_config_tf_server_identity_token) {secrets.tf2_ugc[:identity_token]}

    #HLDS Core Config
    set :hlds_game, "tf"
    set :hlds_user, "hlds"
    set :hlds_root, "/opt/hlds"
    set(:hlds_source) {hlds_root}
    set :hlds_init_dest, '/etc/init.d/hlds'
    set :hlds_update_tool_url, "http://storefront.steampowered.com/download/hldsupdatetool.bin"
    set(:hlds_bindir) {"#{hlds_root}/orangebox"}
    set(:hlds_config_root) {"#{hlds_root}/orangebox/tf/cfg"}
    set(:hlds_config_server_cfg) {"#{hlds_config_root}/server.cfg"}
    set(:hlds_config_rcon_password) {secrets.tf2_ugc[:rcon_password]}
    set(:hlds_parameters) {"-autoupdate -console +maxplayers #{maxplayers} +ip #{server_ip} -port #{server_port} +exec #{server_type_cfg} +map #{hlds_mapcycle.first} +fps_max #{fps_max}"}

    # Servers
    server "#{server_ip}", :hlds_ugc, :postfix_client,  :no_denyhosts => true
  end

end