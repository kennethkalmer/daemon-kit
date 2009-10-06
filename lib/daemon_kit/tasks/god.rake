require 'erb'

namespace :god do
  desc "Generate a stub god config file template for the daemon"
  task :template => 'environment' do
    # Preserve local changes
    if File.exists?( "#{DaemonKit.root}/config/god.erb" ) && ENV['FORCE'].nil?
      puts "Template already exists, use FORCE=1 to overwrite."
      exit 1
    end

    cp "#{DaemonKit.framework_root}/templates/god/god.erb", "#{DaemonKit.root}/config/god.erb"
  end

  desc "Parse the god config template into a god config file"
  task :generate => 'environment' do

    unless File.exists?( "#{DaemonKit.root}/config/god.erb" )
      Rake::Task["god:template"].invoke
    end

    name = DaemonKit.configuration.daemon_name

    File.open( "#{DaemonKit.root}/config/#{name}.god", "w+" ) do |f|
      t = File.read( "#{DaemonKit.root}/config/god.erb" )
      f.write( ERB.new( t ).result( binding )  )
    end

    puts "god config generated in config/#{name}.god"
  end

  desc "Load the god file into god"
  task :load => 'environment' do
    name = DaemonKit.configuration.daemon_name

    sh "#{$RAKE_USE_SUDO ? 'sudo' : ''} god load #{DaemonKit.root}/config/#{name}.god"
  end

  desc "Refresh the god config file in the running god"
  task :refresh => 'environment' do
    name = DaemonKit.configuration.daemon_name

    sh "#{$RAKE_USE_SUDO ? 'sudo' : ''} god unmonitor #{name}"
    sh "#{$RAKE_USE_SUDO ? 'sudo' : ''} god remove #{name}"
    sh "#{$RAKE_USE_SUDO ? 'sudo' : ''} god load #{DaemonKit.root}/config/#{name}.god"
    sh "#{$RAKE_USE_SUDO ? 'sudo' : ''} god monitor #{name}"
  end

  desc "Start god monitoring of the config file"
  task :monitor => 'environment' do
    name = DaemonKit.configuration.daemon_name

    sh "#{$RAKE_USE_SUDO ? 'sudo' : ''} god monitor #{name}"
  end

  desc "Stop god monitoring of the config file"
  task :unmonitor => 'environment' do
    name = DaemonKit.configuration.daemon_name

    sh "#{$RAKE_USE_SUDO ? 'sudo' : ''} god unmonitor #{name}"
  end
end
