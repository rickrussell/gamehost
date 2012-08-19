Capistrano::Configuration.instance(true).load do

  namespace :hlds do 

    set :hlds_mapcycle, %w(mvm_decoy mvm_coaltown mvm_manworks)
    set(:hlds_parameters) {"-autoupdate -maxplyaers 32 +map #{hlds_mapcycle.join(" ")}"}
    set :hlds_motd, "welcome"
    set :hlds_config_hostname, "Filthy Casuals MVM #2"
    set :hlds_config_sv_contact, "donnoman@yahoo.com"
    set :hlds_config_sv_region, "1"  # -1 is the world, 0 is USA east coast, 1 is USA west coast 2 south america, 3 europe, 4 asia, 5 australia, 6 middle east, 7 africa

  end

end