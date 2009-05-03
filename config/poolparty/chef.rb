#include_recipe "mysql::server"

#web_app sets up passenger and theapache virtual host
web_app "my_app" do
  docroot "/var/www/my_app/current/public"
  template "my_app.conf.erb"
  server_name "myapp.com"
  server_aliases [node[:hostname], node[:fqdn], node[:ec2][:public_hostname]]
  rails_env "production"  
end
