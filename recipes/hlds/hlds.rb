Capistrano::Configuration.instance(true).load do

  namespace :hlds do 
    set :hlds_mapcycle, %w(mvm_decoy mvm_coaltown mvm_mannworks)
    set(:hlds_parameters) {"-autoupdate -maxplayers 32 +map #{hlds_mapcycle.first}"}
    set :hlds_motd, "welcome"
  end

end