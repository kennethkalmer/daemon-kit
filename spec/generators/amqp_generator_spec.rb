require 'spec_helper'

describe DaemonKit::Generators::AmqpGenerator do

  before(:each) do
    DaemonKit::Generators::Base.any_instance.stub(:app_name).and_return('specd')
  end

  within_source_root {
    FileUtils.touch "Gemfile"
  }

  it { should append_file("Gemfile", "\ngem 'amqp'\n") }
  it { should generate("config/amqp.yml") }
  it { should generate("config/pre-daemonize/amqp.rb") }
  it { should generate("libexec/specd-daemon.rb") }

end
