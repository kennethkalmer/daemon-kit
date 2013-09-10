require 'spec_helper'

describe DaemonKit::Generators::SqsGenerator do

  before(:each) do
    DaemonKit::Generators::Base.any_instance.stub(:app_name).and_return('specd')
  end

  within_source_root {
    FileUtils.touch "Gemfile"
  }

  it { should append_file("Gemfile", "\ngem 'aws-sdk'\n") }
  it { should generate("config/sqs.yml") }
  it { should generate("config/pre-daemonize/sqs.rb") }
  it { should generate("libexec/specd-daemon.rb") }

end
