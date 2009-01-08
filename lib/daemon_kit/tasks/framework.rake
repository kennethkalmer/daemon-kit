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
        puts "No daemon_kit gem #{version} is installed.  Do 'gem list daemon_kit' to see what you have available."
        exit
      end

      puts "Freezing the gem for DaemonKit #{kit.version}"
      rm_rf   "vendor/daemon_kit"
      mkdir_p "vendor/daemon_kit"

      begin
        chdir("vendor/daemon_kit") do
          kit.dependencies.select { |g| deps.include? g.name }.each do |g|
            Gem::GemRunner.new.run(["unpack", g.name, "--version", g.version_requirements.to_s])
            mv(Dir.glob("#{g.name}*").first, g.name)
          end

          Gem::GemRunner.new.run(["unpack", "daemon-kit", "--version", "=#{version}"])
          FileUtils.mv(Dir.glob("daemon-kit*").first, "daemon-kit")
        end
      rescue Exception
        rm_rf "vendor/daemon_kit"
        raise
      end
    end

    desc 'Lock to latest edge daemon_kit'
    task :edge do
      require 'open-uri'
      #version = ENV["RELEASE"] || "edge"
      commits = "http://github.com/api/v1/yaml/kennethkalmer/daemon-kit/commits/master"
      url     = "http://github.com/kennethkalmer/daemon-kit/zipball/master"

      rm_rf   "vendor/daemon_kit"
      mkdir_p "vendor/daemon_kit"
      
      chdir 'vendor/daemon_kit' do
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
end
