namespace :daemon_kit do

  desc "Upgrade your local files for a daemon after upgrading daemon-kit"
  task :upgrade => 'environment' do
    # Run these
    %w{ initializers rakefile scripts gemfile }.each do |t|
      Rake::Task["daemon_kit:upgrade:#{t}"].invoke
    end

    puts
    puts "#{DaemonKit.configuration.daemon_name} has been upgraded."
  end

  namespace :upgrade do
    # Upgrade the initializers
    task :initializers do
      copy_framework_template( 'config', 'boot.rb' )

      if File.directory?( File.join(DaemonKit.root, 'config', 'initializers') )
        mv File.join(DaemonKit.root, 'config', 'initializers'), File.join(DAEMON_ROOT, 'config', 'pre-daemonize')
        copy_framework_template( 'config', 'pre-daemonize', 'readme' )
      end

      unless File.directory?( File.join(DAEMON_ROOT, 'config', 'post-daemonize') )
        mkdir_p File.join(DAEMON_ROOT, 'config', 'post-daemonize')
        copy_framework_template( 'config', 'post-daemonize', 'readme' )
      end
    end

    # Upgrade the Rakefile
    task :rakefile do
      copy_framework_template( 'Rakefile' )
    end

    # Upgrade the scripts
    task :scripts do
      %w{ console destroy generate }.each do |s|
        copy_framework_template( "script", s )
      end
    end

    # Upgrade the Gemfile
    task :gemfile do
      copy_framework_template( 'Gemfile' )
    end
  end
end

def copy_framework_template( *args )
  src_dir = File.join(DaemonKit.framework_root, 'lib', 'generators', 'daemon_kit', 'app', 'templates')
  cp File.join( src_dir, *args ), File.join( DaemonKit.root, *args )
end
