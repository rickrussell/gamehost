# =============================================================================
# RECIPE INCLUDES
# https://github.com/demandchain/cap-recipes/tree/master/lib/cap_recipes/tasks
# =============================================================================

require 'cap_recipes/tasks/utilities'
require 'cap_recipes/tasks/provision'
require 'cap_recipes/tasks/teelogger'
require 'cap_recipes/tasks/denyhosts'
require 'cap_recipes/tasks/ssh'
require 'cap_recipes/tasks/hlds'
#require 'cap_recipes/tasks/nginx'
#require 'cap_recipes/tasks/ruby19'
#require 'cap_recipes/tasks/bundler'
#require 'cap_recipes/tasks/god'

# =============================================================================
# PROJECT RECIPES
# =============================================================================

Dir[File.join(File.dirname(__FILE__), '../recipes/**/*.rb')].each { |task| require(task) }

# =============================================================================
# PROJECT Settings
# =============================================================================

set :application, "gamehost"
ssh_options[:forward_agent] = true
#ssh_options[:verbose] = :debug 
default_run_options[:pty] = true



# =============================================================================
# PROJECT STAGES
# =============================================================================

Dir[File.join(File.dirname(__FILE__), '../stages/**/*.rb')].each { |task| require(task) }

