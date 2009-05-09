pool :application do
  instances 1
  keypair "~/.ec2/testpair"       #you need to modify this to point to your EC2 key file

  cloud :app do
    has_gem_package "rails", :version => "2.3.2"    #must match the version specified in the rails environment.rb
    has_package "mysql-client"
    has_package "mysql-server"
    has_package "libmysqlclient15-dev"    #so we can install the mysql gem
    has_gem_package "mysql"               #so rails can talk to mysql
    has_service "mysql"                   #run the mysql server

    has_file "/etc/motd", :content => "Welcome!"                    #login message (message-of-the-day)
    
    has_rails_deploy "my_app" do                                    #deploy our rails app using apache + mod_rails/passenger  
      dir "/var/www"
      repo "git://github.com/emiltin/poolparty_example.git"         #download rails app from this repo
      user "www-data"
      database_yml "#{File.dirname(__FILE__)}/../database.yml"      #will copy it to the shared folder
      
      
      #the problem with this is that rails_deploy doesn't currently pass on the migration_command to chef_deploy...
      migration_command "rake db:create && RAILS_ENV=production rake db:migrate"
    end

    chef do
      include_recipes "#{File.dirname(__FILE__)}/../cookbooks/*"     #will be uploaded to instances, but not run
      templates "#{File.dirname(__FILE__)}/templates/"               #will be uploaded to instances
      recipe "#{File.dirname(__FILE__)}/chef.rb"                     #will be uploaded to instances, and run 
    end    
    
  end

end
