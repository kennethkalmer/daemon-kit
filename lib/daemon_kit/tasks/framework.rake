namespace :daemon_kit do
  namespace :freeze do
    desc "Lock this application to the current gem (by unpacking it into vendor/daemon_kit)"
    task :gems do
      deps = %w()
      require 'rubygems'
      require 'rubygems/gem_runner'

      kit = (version = ENV['VERSION']) ?
        Gem.cache.find_name('daemon-kit', "= #{version}").first :
        Gem.cache.find_name('daemon-kit').sort_by { |g| g.version }.last

      version ||= kit.version

      unless kit
        puts "No daemon_kit gem #{version} is installed.  Do 'gem list daemon-kit' to see what you have available."
        exit
      end

      puts "Freezing the gem for DaemonKit #{kit.version}"
      mkdir_p "vendor"

      begin
        chdir("vendor") do
          kit.dependencies.select { |g| deps.include? g.name }.each do |g|
            Gem::GemRunner.new.run(["unpack", g.name, "--version", g.version_requirements.to_s])
            mv(Dir.glob("#{g.name}*").first, g.name)
          end

          Gem::GemRunner.new.run(["unpack", "daemon-kit", "--version", "=#{version}"])
          FileUtils.mv(Dir.glob("daemon-kit*").first, "daemon-kit")
        end
      rescue Exception
        rm_rf "vendor/daemon-kit"
        raise
      end
    end

    desc 'Lock to latest edge daemon_kit'
    task :edge do
      require 'open-uri'
      #version = ENV["RELEASE"] || "edge"
      commits = "http://github.com/api/v1/yaml/kennethkalmer/daemon-kit/commits/master"
      url     = "http://github.com/kennethkalmer/daemon-kit/zipball/master"

      rm_rf   "vendor/daemon-kit"

      chdir 'vendor' do
        latest_revision = YAML.load(open(commits))["commits"].first["id"]

        puts "Downloading DaemonKit from #{url}"
        File.open('daemon-kit.zip', 'wb') do |dst|
          open url do |src|
            while chunk = src.read(4096)
              dst << chunk
            end
          end
        end

        puts 'Unpacking DaemonKit'
        rm_rf 'daemon-kit'
        `unzip daemon-kit.zip`
        FileUtils.mv(Dir.glob("kennethkalmer-daemon-kit*").first, "daemon-kit")
        %w(daemon-kit.zip).each do |goner|
          rm_f goner
        end

        touch "REVISION_#{latest_revision}"
      end
    end

  end

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
