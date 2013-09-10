require 'spec_helper'

describe DaemonKit::Generators::CronGenerator do

  before(:each) do
    DaemonKit::Generators::Base.any_instance.stub(:app_name).and_return('specd')
  end

  within_source_root {
    FileUtils.touch "Gemfile"
  }

  it { should append_file("Gemfile", "\ngem 'rufus-scheduler', '>= 2.0.3'\n") }
  it { should generate("config/pre-daemonize/cron.rb") }
  it { should generate("libexec/specd-daemon.rb") }

end
