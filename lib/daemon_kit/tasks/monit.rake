require 'erb'

namespace :monit do
  desc "Generate a stub monit config file template for the daemon"
  task :template => 'environment' do
    # Preserve local changes
    if File.exists?( "#{DaemonKit.root}/config/monit.erb" ) && ENV['FORCE'].nil?
      puts "Template already exists, use FORCE=1 to overwrite."
      exit 1
    end

    cp "#{DaemonKit.framework_root}/templates/monit/monit.erb", "#{DaemonKit.root}/config/monit.erb"
  end

  desc "Parse the monit config template into a monit config file"
  task :generate => 'environment' do

    unless File.exists?( "#{DaemonKit.root}/config/monit.erb" )
      Rake::Task["monit:template"].invoke
    end

    File.open( "#{DaemonKit.root}/config/monit.conf", "w+" ) do |f|
      t = File.read( "#{DaemonKit.root}/config/monit.erb" )
      f.write( ERB.new( t ).result( binding )  )
    end

    puts "Monit config generated in config/monit.conf"
  end
end
