require 'spec_helper'

DEFAULT_APP_FILES = %w(
  README
  Rakefile
  bin/specd
  config/arguments
  config/boot.rb
  config/environments/development.rb
  config/environments/test.rb
  config/environments/production.rb
  config/pre-daemonize/readme
  config/post-daemonize/readme
  lib/specd.rb
  libexec/specd-daemon.rb
  log
  script/console
  script/destroy
  script/generate
  spec/spec_helper
  tasks
  vendor
  tmp
)

describe DaemonKit::Generators::AppGenerator do

  with_args 'specd' do
    pending "should generate all the default files" do
      DEFAULT_APP_FILES.each do |f|
        subject.should generate(f)
      end
    end
  end

  with_args 'specd', '-d', 'capistrano' do
    pending "should generate capistrano config" do
      subject.should generate("Capfile")
    end
  end

end
