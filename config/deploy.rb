# Capistrano deploy specification.
# Integrated with poolparty by getting node addresses from poolparty, and use them to set cap roles.


#gain access to poolparry node info
require 'poolparty'
require 'clouds.rb'

main_cloud = :app


#extract the hostnames of running instances from a poolparty cloud
def find_running_nodes cloud
  clouds[cloud].nodes(:status=>"running").map { |node| node.hostname }
end

#find the rails deploy object so we can extract info
def find_rails_deploy cloud
  clouds[cloud].ordered_resources.find { |node| node.is_a? RailsDeployClass }
end

#assign cap roles to pp nodes
nodes = find_running_nodes(main_cloud)     #get addresses of running instance in the poolparty cloud named 'app'
role :app, *nodes
role :web, *nodes
role :db, *nodes

# you must have both the public and the private key in the same folder, the public key should have the extension ".pub"
# you can generate a public key from your private key by using 'ssh-keygen -y' on the command line
ssh_options[:keys] =  clouds[main_cloud].keypair.filepath         #use the keyfile pointed to in clouds.rb
ssh_options[:user] =  "root"


#use info from the rails_deploy block in clouds.rb to set deploy stuff
deployer = find_rails_deploy(main_cloud) || raise("Can't find rails deploy object in clouds.rb!")
deploy_dir = "#{deployer.dsl_options[:dir]}/#{deployer.dsl_options[:name]}"
set :scm, "git"
set :application, deployer.dsl_options[:name]
set :repository, deployer.dsl_options[:repo]
set :deploy_to, deploy_dir


set :branch, "master"
set :deploy_via, :remote_cache
#set :user, "deployer"
#default_run_options[:pty] = true
#ssh_options[:forward_agent] = true


desc <<-DESC
Run whoami on the nodes.
DESC
task :stats do
  run "cd #{deploy_dir}/current && RAILS_ENV=production rake stats"
end


desc "tail production log files" 
task :logs, :roles => :app do
  run "tail -f #{deploy_dir}/shared/log/production.log" do |channel, stream, data|
    puts
    puts "#{channel[:host]}: #{data}"
#    printf '...'
    break if stream == :err    
  end
end
