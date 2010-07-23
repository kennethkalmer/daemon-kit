task :environment do
  $daemon_kit_rake_task = true

  require 'config/environment'
  DaemonKit::Application.running!
end

task "Execute system commands in other tasks with sudo"
task :sudo do
  $RAKE_USE_SUDO = true
end
