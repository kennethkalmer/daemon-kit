task :environment do
  $daemon_kit_rake_task = true

  require 'config/environment'

  # Possible adjustments to the environment?
  if File.exists?( File.join( DaemonKit.root, 'ENVIRONMENT' ) )
    begin
      updated_env = YAML.load_file( File.join( DaemonKit.root, 'ENVIRONMENT' ) )
      if updated_env['daemon_root'] && File.directory?( updated_env['daemon_root'] )
        ::DAEMON_ROOT.replace( updated_env['daemon_root'] )
      end

      $daemon_kit_ruby_path = updated_env['ruby_path']
    rescue
      # We should trap YAML specific parse errors and report
    end
  end
end

task "Execute system commands in other tasks with sudo"
task :sudo do
  $RAKE_USE_SUDO = true
end
