# this file is just for convenience.
# by poolparty poolparty looks for 'clouds.rb' in the current directory, 
# so by having this file we don't have to specify the location of the clouds.rb file 
# when we run poolparty commands from the root of the rails folder

require "#{File.dirname(__FILE__)}/config/poolparty/clouds.rb"