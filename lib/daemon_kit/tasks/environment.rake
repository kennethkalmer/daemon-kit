task :environment do
  # This relies on the fact that rake changes the currect working
  # directory to the directory where the Rakefile is located, thus
  # implying DAEMON_ROOT.
  DAEMON_ROOT = '.'
  $daemon_kit_rake_task = true

  require 'config/environment'
end
