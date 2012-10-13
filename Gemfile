source "https://rubygems.org"

# Helper method to work with gems under development.
# clone them to vendor/checkouts/<gem-name>
# You only need this option if you have a development gem actually checked out in the correct location.
# When you want to bundle a Gemfile.lock for committing, use:
# NOGEMDEV=1 bundle
def gem_dev(gem_name,options={})
  if File.exists?(path = File.join("vendor/checkouts/",gem_name)) && !ENV['NOGEMDEV']
    gem gem_name, options.reject{|k,v| [:git,:ref].include?(k)}.merge(:path => path)
  else
    gem gem_name, options
  end
end

gem "debugger"
gem "capistrano"
gem_dev 'cap-recipes', :git => "git@github.com:rickrussell/cap-recipes.git", :require => false
