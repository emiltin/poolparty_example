pool :application do
  instances 1
  keypair "~/.ec2/testpair"
  
  cloud :app do
    has_package "git-core"
    has_package "libsqlite3-dev"

    has_gem_package "rails", :version => "2.3.2"
    has_gem_package "sqlite3-ruby"

    has_directory "/var/www"
    has_directory "/var/www/my_app"
    has_directory "/var/www/my_app/shared", :owner => "www-data"
    %w(config pids log).each do |dir|
      has_directory "/var/www/my_app/shared/#{dir}"
    end
    
    has_file "/var/www/my_app/shared/config/database.yml" do
      content '# SQLite version 3.x
production:
  adapter: sqlite3
  database: db/production.sqlite3
  pool: 5
  timeout: 5000
'
    end

    has_chef_deploy "/var/www/my_app" do
      repo "git://github.com/emiltin/poolparty_example.git"         #download rails app from git repo
      user "www-data"
    end
            
    chef do
      include_chef_recipe "sqlite"
      include_recipes "#{File.dirname(__FILE__)}/../cookbooks/*"     #will be uploaded to instances, but not run
      templates "#{File.dirname(__FILE__)}/templates/"               #will be uploaded to instances
      recipe "#{File.dirname(__FILE__)}/chef.rb"                     #will be uploaded to instances, and run 
    end    
    
  end
 
end
