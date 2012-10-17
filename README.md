gamehost
========
![Valve Logo](http://valvesoftware.com/images/header_logo.png) Un-Official Valve Half-Life Dedicated Server Deployment using Ruby Capistrano Scripts


For now we just have 2 stages;

1. Tf2 Standard Server
2. Tf2 UGC Highlander Server

You will need a [MacOSX Ruby Development Environment](https://github.com/rickrussell/cap-recipes/wiki/Mac-osx-ruby-development-environment) or a Linux Ruby Development Environment with RVM

You will also need passwordless ssh access with sudo/root permissions.  

###Clone cap-recipes and gamehost and prepare local files

```bash
git clone git@github.com:rickrussell/gamehost.git
git clone git@github.com:rickrussell/cap-recipes.git
  
cd cap-recipes
cp .rvmrc.template .rvmrc
cd .

cd gamehost
cp .rvmrc.template .rvmrc
cd .
cp config/secrets.rb.template config/secrets.rb
```
#### Set up secrets.rb
Use your editor and configure your secrets.rb.  You need to make sure to set all options.  
```bash
edit config/secrets.rb
```
```ruby
def tf2_standard
  {
    :identity_account_id => "987654321",
    :identity_token => "l337-7ok3n",
    :server_ip => "123.45.67.89",
    :hostname => '"TF2 Server"',
    :rcon_password => "looneytunes"
  }
end
```
#### Prepare Stages & Roles
Setup your stage files. Make sure ports, players and fps settings are correct.
```bash
edit stages/tf2_stadard.rb
```
```ruby
#HLDS Custom Settings (requires)
set :fps_max, "1000"
set :maxplayers, "18"
set :server_port, "27015"
set :hlds_mapcycle, %w(pl_swiftwater_ugc)
set :server_type_cfg, "ugc_HL_stopwatch.cfg" # "server.cfg" (default), "ugc_HL_standard" (standard), "ugc_HL_koth.cfg" (King of the Hill), "ugc_HL_dom.cfg" (Domination), "ugc_HL_ctf.cfg" (CTF)
```
After you have both stages configured correctly, we can deploy.  Make sure you have ssh keys pushed to your server and you have sudo access as stated above.
Let's deploy a standard tf2 server:
```bash
bin/cap tf2_standard hlds:install
```
or for a UGC Highlander Server:
```bash
bin/cap tf2_ugc hlds:install
```
You should see output from Capistrano.  Take a break, let Steam install/update and eat a Sandvich! ![Sandvich!](http://wiki.teamfortress.com/w/images/thumb/9/95/Sandvich.png/250px-Sandvich.png)
