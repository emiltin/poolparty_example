require "poolparty-extensions"      #you must have the auser-poolparty-extensions gem installed

pool :application do
  instances 1
  keypair "~/.ec2/testpair"       #you need to modify this to point to your EC2 key file

  cloud :app do
    has_gem_package "rails", :version => "2.3.2"
    has_package "mysql-client"
    has_package "mysql-server"
    has_gem_package "mysql"
    has_service "mysql"

    has_file "/etc/motd", :content => "Welcome to your poolparty example instance!"   #login welcome message
    has_exec "updatedb"                                                               #make the command line 'locate' tool work
    
    #deploy our rails app using apache + mod_rails/passenger
    has_rails_deploy "my_app" do
      dir "/var/www"
      repo "git://github.com/emiltin/poolparty_example.git"
      user "www-data"
      database_yml "#{File.dirname(__FILE__)}/../database.yml"
    end

    chef do
      include_recipes "#{File.dirname(__FILE__)}/../cookbooks/*"     #will be uploaded to instances, but not run
      templates "#{File.dirname(__FILE__)}/templates/"               #will be uploaded to instances
      recipe "#{File.dirname(__FILE__)}/chef.rb"                     #will be uploaded to instances, and run 
    end    
    
  end

end
