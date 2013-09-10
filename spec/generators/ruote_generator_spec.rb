require 'spec_helper'

describe DaemonKit::Generators::RuoteGenerator do

  before(:each) do
    DaemonKit::Generators::Base.any_instance.stub(:app_name).and_return('specd')
  end

  within_source_root {
    FileUtils.touch "Gemfile"
  }

  it { should append_file("Gemfile", "gem 'amqp'\n") }
  it { should append_file("Gemfile", "gem 'json'\n") }
  it { should generate("config/amqp.yml") }
  it { should generate("config/ruote.yml") }
  it { should generate("config/pre-daemonize/ruote.rb") }
  it { should generate("lib/specd.rb") }
  it { should generate("lib/sample.rb") }

end
