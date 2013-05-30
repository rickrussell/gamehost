Capistrano::Configuration.instance(true).load do

  task :csgo_lookout do
    # make empty roles
    roles[:csgo_ds]

    ENV['NOTIFY']='0'
    set :rails_env, :csgo_ds
    set :bundler_opts, %w(--deployment --no-color)
    set :target_os, :debian64
    ssh_options[:forward_agent] = true
    ssh_options[:paranoid] = false
    set :run_method, :sudo
    set :sudoers_file, File.join(File.dirname(__FILE__), '..', 'recipes', 'sudoers', 'csgo')

    #csgo_ds Custom Settings (requires)
    set :fps_max, "1000"
    set :maxplayers, "24"
    set :server_port, "27015"
    set :csgo_ds_mapcycle, %w(cp_granary ctf_turbine pl_badwater cp_badlands pl_hoodoo_final pl_upward cp_coldfront cp_dustbowl koth_nucleus)
    set :server_type_cfg, "server.cfg" # "server.cfg" (default), "ugc_HL_standard" (standard), "ugc_HL_koth.cfg" (King of the Hill), "ugc_HL_dom.cfg" (Domination), "ugc_HL_ctf.cfg" (CTF)
    set(:sudeors_username) {secrets.sudeors_credentials[:username]}
    set(:chef_password) {secrets.chef[:password]}
    set(:server_ip) {secrets.csgo_lookout[:server_ip]}
    set(:csgo_ds_config_hostname) {secrets.csgo_lookout[:hostname]}
    set(:csgo_ds_config_sv_contact) {secrets.csgo_lookout[:sv_contact]}
    set(:csgo_ds_server_identity_account_id) {secrets.csgo_lookout[:identity_account_id]}
    set(:csgo_ds_server_identity_token) {secrets.csgo_lookout[:identity_token]}

    #csgo_ds Core Config
    set :steamapp_type, "csgo"
    set(:csgo_ds_parameters) {"-autoupdate -console +maxplayers #{maxplayers} +ip #{server_ip} -port #{server_port} +exec #{server_type_cfg} +map #{csgo_ds_mapcycle.first} +fps_max #{fps_max} -debug"}

    # Servers
    server "#{server_ip}", :csgo_ds, :postfix_client,  :no_denyhosts => true
  end

end