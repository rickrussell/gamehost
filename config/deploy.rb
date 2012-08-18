# =============================================================================
# RECIPE INCLUDES
# https://github.com/demandchain/cap-recipes/tree/master/lib/cap_recipes/tasks
# =============================================================================

require 'cap_recipes/tasks/utilities'
require 'cap_recipes/tasks/provision'
require 'cap_recipes/tasks/teelogger'
require 'cap_recipes/tasks/bundler'
require 'cap_recipes/tasks/god'
require 'cap_recipes/tasks/denyhosts'
require 'cap_recipes/tasks/nginx'

set :application, "gamehost"

# =============================================================================
# PROJECT RECIPES
# =============================================================================

Dir[File.join(File.dirname(__FILE__), '../recipes/**/*.rb')].each { |task| require(task) }


# =============================================================================
# PROJECT STAGES
# =============================================================================

Dir[File.join(File.dirname(__FILE__), '../stages/**/*.rb')].each { |task| require(task) }

