node[:apache][:dir] = "/etc/apache2"
include_recipe "apache2"
include_recipe "passenger"
include_recipe "sqlite"
  
web_app "my_app" do
  docroot "/var/www/my_app/current/public"
  template "my_app.conf.erb"    #full path on the instance
  server_name "myapp.com"
  server_aliases [node[:hostname], node[:fqdn], node[:ec2][:public_hostname]]
  rails_env "production"  
end
