Capistrano::Configuration.instance(:must_exist).load do

  #these two log file tasks are based on http://errtheblog.com/posts/19-streaming-capistrano
  #they are modified to handle different deployment stages
  
  desc "tail production log files" 
  task :tail_logs, :roles => :app do
    run "tail -f #{shared_path}/log/#{stage}.log" do |channel, stream, data|
      puts
      puts "#{channel[:host]}: #{data}"
  #    printf '...'
      break if stream == :err    
    end
  end

  desc "check production log files in textmate(tm)" 
  task :mate_logs, :roles => :app do
    require 'tempfile'
    tmp = Tempfile.open('w')
    logs = Hash.new { |h,k| h[k] = '' }

    run "tail -n 500 #{shared_path}/log/#{stage}.log" do |channel, stream, data|
      logs[channel[:host]] << data
      break if stream == :err
    end

    logs.each do |host, log|
      tmp.write("--- #{host} ---\n\n")
      tmp.write(log + "\n")
    end

    tmp.flush
    `mate -w -l 99999999 #{tmp.path}`     #place cursor at some huge line nr to go to end of file
    tmp.close
  end

end