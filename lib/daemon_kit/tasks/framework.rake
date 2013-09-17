namespace :daemon_kit do

  desc "Upgrade your local files for a daemon after upgrading daemon-kit"
  task :upgrade => 'environment' do
    # Run these
    %w{ config root scripts }.each do |t|
      Rake::Task["daemon_kit:upgrade:#{t}"].invoke
    end

    puts
    puts "#{DaemonKit.configuration.daemon_name} has been upgraded."
  end

  namespace :upgrade do
    def invoke_from_app_generator(method)
      app_generator.send(method)
    end

    def app_generator
      @app_generator ||= begin
        require 'daemon_kit/generators'

        name = DaemonKit.configuration.daemon_name
        gen = DaemonKit::Generators::AppGenerator.new( [name], { :with_dispatchers => true },
                                                      :destination_root => DaemonKit.root )
        gen
      end
    end

    task :config do
      invoke_from_app_generator(:create_config_files)
    end

    task :root do
      invoke_from_app_generator(:create_root_files)
    end

    task :scripts do
      invoke_from_app_generator(:create_script_files)
    end
  end
end
