require 'spec_helper'

describe DaemonKit::Generators::CapistranoGenerator do

  before(:each) do
    DaemonKit::Generators::Base.any_instance.stub(:app_name).and_return('specd')
  end

  within_source_root {
    FileUtils.touch "Gemfile"
  }

  it { should append_file("Gemfile", "\ngem 'capistrano'\n") }
  it { should append_file("Gemfile", "\ngem 'capistrano-ext'\n") }
  it { should generate("Capfile") }
  it { should generate("config/deploy.rb") }
  it { should generate("config/deploy/staging.rb") }
  it { should generate("config/deploy/production.rb") }

end
