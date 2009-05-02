require "poolparty-extensions"

pool :application do
  instances 1
  keypair "~/.ec2/testpair"

  cloud :app do
    has_package "libsqlite3-dev"
    has_gem_package "rails", :version => "2.3.2"
    has_gem_package "sqlite3-ruby"
    include_chef_recipe "sqlite"

    has_file "/etc/motd", :content => "Welcome to your poolparty example instance!"

    #includes the git-core package, and apache and mod_rails chef recipes
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
