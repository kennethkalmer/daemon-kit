require 'rubygems'
gem 'hoe', '>= 2.3.0'
require 'hoe'
require 'fileutils'
require File.dirname(__FILE__) + '/lib/daemon_kit'

Hoe.plugin :newgem
Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
Hoe.spec "daemon-kit" do
  developer "Kenneth Kalmer", "kenneth.kalmer@gmail.com"
  summary = "Daemon Kit aims to simplify creating Ruby daemons by providing a sound application skeleton (through a generator), task specific generators (jabber bot, etc) and robust environment management code."
  changes = paragraphs_of("History.txt", 0..1).join("\n\n")
  post_install_message = IO.read( 'PostInstall.txt' ) # TODO remove if post-install message not required
  rubyforge_name = "kit" # TODO this is default value
  extra_deps = [
    ["rubigen", ">= 1.5.2"],
    ["eventmachine", ">=0.12.8"]
  ]
  extra_dev_deps = [
    ["newgem", ">= #{::Newgem::VERSION}"]  ]

  clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (rubyforge_name == name) ? rubyforge_name : "\#{rubyforge_name}/\#{name}"
  remote_rdoc_dir = File.join(path.gsub(/^#{rubyforge_name}\/?/, ""), "rdoc")
  rsync_args = "-avz --delete --ignore-errors"
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
task :default => [:spec] #, :features]