Capistrano::Configuration.instance(true).load do

  task :csgo_lookout do
    roles[:csgo_ds]
    ENV['NOTIFY']='0'
    set :rails_env, :csgo_ds
    set :bundler_opts, %w(--deployment --no-color)
    set :target_os, :ubuntu64
    ssh_options[:forward_agent] = true
    ssh_options[:paranoid] = false
    set :run_method, :sudo
    set :steamcmd_user, "steam"

    #csgo_ds Custom Settings (requires)
    set :fps_max, "1000"
    set :maxplayers, "16"
    set :server_port, "27015"
    set :csgo_ds_mapcycle_array, %w(cs_italy de_dust de_aztec cs_office de_dust2 de_train de_inferno de_nuke)
    set :csgo_ds_mapcycle, "cs_italy de_dust de_aztec cs_office de_dust2 de_train de_inferno de_nuke"
    set(:server_ip) {secrets.csgo_lookout[:server_ip]}
    set(:csgo_ds_config_hostname) {secrets.csgo_lookout[:hostname]}
    set(:csgo_ds_config_sv_contact) {secrets.csgo_lookout[:sv_contact]}
    set(:csgo_ds_server_identity_account_id) {secrets.csgo_lookout[:identity_account_id]}
    set(:csgo_ds_server_identity_token) {secrets.csgo_lookout[:identity_token]}
    set(:csgo_ds_rcon_password) {secrets.csgo_lookout[:rcon_password]}

    #csgo_ds Core Config
    set :steamapp_type, "csgo"
    set(:csgo_ds_parameters) {"./srcds_run -game ${GAME_NAME} -console -usercon -ip ${GAME_IP} -port ${GAME_PORT} +fps_max ${GAME_FPS} +game_type ${GAME_TYPE} +game_mode ${GAME_MODE} -maxplayers_override ${MAX_PLAYERS} +map ${GAME_MAP} -autoupdate -steamcmd_script ${STEAMCMD} -steam_dir ${STEAM_DIR}"}

    # Servers
    server "#{server_ip}", :csgo_ds, :postfix_client,  :no_denyhosts => true
  end

end